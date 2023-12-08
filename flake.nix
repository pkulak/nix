{
  description = "Phil's Flake";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url   = "github:NixOS/nixos-hardware";
    nur.url              = "github:nix-community/NUR";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = ""; # don't download OSX deps
    };
    
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix, nixos-hardware, nur, home-manager, agenix, nix-index-database }: let
    mkSystem = host: nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      
      specialArgs = {
        inherit nixos-hardware;
        inherit nur;

        pkgs-unstable = import nixpkgs-unstable {
          config.allowUnfree = true;
          localSystem = { inherit system; };
        };
      };
      
      modules = [
        ./configuration.nix
        ./hosts/${host}

        agenix.nixosModules.default

        { environment.systemPackages = [ agenix.packages.${system}.default ]; }

        {
          age = {
            secrets = {
              "jmap-secrets" = {
                file = ./secrets/jmap-secrets.age;
                owner = "phil";
                group = "users";
                mode = "600";
              };
              "smb-secrets".file = ./secrets/smb-secrets.age;
              "1pass".file = ./secrets/1pass.age;
            };
          };
        }

        nix-index-database.nixosModules.nix-index

        {
          programs.command-not-found.enable = false;
          programs.nix-index-database.comma.enable = true;
        }

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.phil = import ./home;
          home-manager.extraSpecialArgs = { inherit host; };
        }
      ];
    };
  in {
    nixosConfigurations = {
      fry   = mkSystem "fry";
      x1    = mkSystem "x1";
      t460p = mkSystem "t460p";
      kvm   = mkSystem "kvm";
    };
  };
}

# sudo nixos-rebuild --flake .#host switch

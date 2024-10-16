{
  description = "Phil's Flake";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url   = "github:NixOS/nixos-hardware";
    nur.url              = "github:nix-community/NUR";

    matui = {
      url = "github:pkulak/matui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    filtile = {
      url = "github:pkulak/filtile";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = ""; # don't download OSX deps
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self,
    nixpkgs, nixpkgs-unstable,
    matui, filtile, nixvim,
    nixos-hardware, nur, home-manager, agenix, nix-index-database
  }: let
    mkSystem = host: nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      
      specialArgs = let
        pkgs-unstable = import nixpkgs-unstable {
          config.allowUnfree = true;
          localSystem = { inherit system; };
        };

        my-nixvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
          module = ./common/nixvim/config;
        };
      in {
        inherit pkgs-unstable;
        inherit nixos-hardware;
        inherit nur;
        inherit matui;
        inherit filtile;
        nixvim = my-nixvim;
      };
      
      modules = [
        ./configuration.nix
        ./hosts/${host}

        agenix.nixosModules.default

        { environment.systemPackages = [ agenix.packages.${system}.default ]; }

        {
          age = {
            secrets = {
              "login.keyring" = {
                file = ./secrets/login.keyring.age;
                owner = "phil";
                group = "users";
                mode = "600";
              };
              "smb-secrets".file = ./secrets/smb-secrets.age;
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

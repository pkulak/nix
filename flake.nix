{
  description = "Phil's Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matui = {
      url = "github:pkulak/matui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = ""; # don't download OSX deps
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "git+file:///home/phil/Projects/nixcats";
      # url = "github:pkulak/neovim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      mkSystem = host: inputs.nixpkgs.lib.nixosSystem rec {
        inherit system;

        specialArgs = {
          inherit pkgs-unstable system;
          inherit (inputs) nixos-hardware nur matui neovim agenix;
        };

        modules = [
          ./configuration.nix
          ./hosts/${host}

          inputs.nix-index-database.nixosModules.nix-index

          {
            programs.command-not-found.enable = false;
            programs.nix-index-database.comma.enable = true;
          }

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.phil = import ./home;

            home-manager.extraSpecialArgs = {
              inherit host system pkgs-unstable;
              inherit (inputs) agenix;
            };

            home-manager.sharedModules = [
              inputs.agenix.homeManagerModules.default
            ];
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        fry = mkSystem "fry";
        x1 = mkSystem "x1";
        kvm = mkSystem "kvm";
      };
    };
}

# sudo nixos-rebuild --flake .#host switch

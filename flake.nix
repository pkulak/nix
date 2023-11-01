{
  description = "Phil's Flake";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url   = "github:NixOS/nixos-hardware";
    nur.url = "github:nix-community/NUR";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix, nixos-hardware, nur, home-manager }: let
    mkSystem = host: nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      
      specialArgs = {
        inherit nixos-hardware;
        inherit nur;
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      };
      
      modules = [
        ./configuration.nix
        ./hosts/${host}

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

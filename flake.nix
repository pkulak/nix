{
  description = "Phil's Flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-23.05";
    nixos-hardware.url   = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix, nixos-hardware }: {
    nixosConfigurations = {
      fry = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        
        specialArgs = {
          inherit nixos-hardware;
          pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
        };
        
        modules = [
          ./configuration.nix
          ./hosts/fry
        ];
      };

      kvm = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        
        specialArgs = {
          inherit nixos-hardware;
          pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
        };
        
        modules = [
          ./configuration.nix
          ./hosts/kvm
        ];
      };
    };
  };
}

# sudo nixos-rebuild --flake .#host switch

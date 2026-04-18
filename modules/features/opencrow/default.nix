{ inputs, ... }:
{
  flake.homeModules.opencrow = import ./home.nix;
  flake.nixosModules.opencrow = import ./nixos.nix { inherit inputs; };
}

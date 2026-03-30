{ self, inputs, ... }: {
  flake.nixosModules.niri = ./nixos.nix;
  flake.homeModules.niri = ./home.nix;
}

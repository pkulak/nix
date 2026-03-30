{ self, inputs, ... }: {
  flake.nixosModules._1password = import ./nixos.nix;
}

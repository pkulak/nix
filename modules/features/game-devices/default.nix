{ self, ... }: {
  flake.nixosModules.game-devices = import ./nixos.nix;
}

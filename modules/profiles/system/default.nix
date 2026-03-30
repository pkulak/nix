{ self, inputs, ... }: {
  flake.nixosModules.system = { ... }: {
    imports = [
      self.nixosModules.smb
      self.nixosModules.snapper
      self.nixosModules.game-devices
      self.nixosModules.nix-index
    ];
  };
}

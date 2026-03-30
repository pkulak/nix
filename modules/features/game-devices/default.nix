{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.game-devices = pkgs.callPackage ./nixos.nix {};
  };
  flake.nixosModules.game-devices = { pkgs, ... }: {
    services.udev.packages = [ self.packages.${pkgs.system}.game-devices ];
  };
}

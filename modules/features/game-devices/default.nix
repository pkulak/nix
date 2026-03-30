{ self, ... }: {
  perSystem = { pkgs, ... }: {
    packages.game-devices = pkgs.callPackage ./package.nix {};
  };
  flake.nixosModules.game-devices = { pkgs, ... }: {
    services.udev.packages = [ self.packages.${pkgs.system}.game-devices ];
  };
}

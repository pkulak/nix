{ self, ... }: {
  perSystem = { pkgs, ... }: {
    packages.pixlet = pkgs.callPackage ./package.nix {};
  };
}

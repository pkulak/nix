{ self, ... }: {
  perSystem = { pkgs, ... }: {
    packages.pgen = pkgs.callPackage ./package.nix {};
  };
}

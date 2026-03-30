{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.pgen = pkgs.callPackage ./nixos.nix {};
  };
}

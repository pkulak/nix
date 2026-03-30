{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.pixlet = pkgs.callPackage ./nixos.nix {};
  };
}

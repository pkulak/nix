{ self, inputs, ... }: {
  flake.nixosModules.jai = import ./nixos.nix;
  flake.homeModules.jai = import ./home.nix;
}

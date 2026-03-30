{ self, inputs, ... }: {
  flake.nixosModules.jai = ./nixos/nixos.nix;
  flake.homeModules.jai = ./home/home.nix;
}

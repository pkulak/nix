{ self, inputs, ... }: {
  flake.nixosModules.fish = import ./nixos.nix;
  flake.homeModules.fish = import ./home.nix;
}

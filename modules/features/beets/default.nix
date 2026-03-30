{ self, inputs, ... }: {
  flake.homeModules.beets = import ./home.nix;
}

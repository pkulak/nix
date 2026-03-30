{ self, inputs, ... }: {
  flake.homeModules.ghostty = import ./home.nix;
}

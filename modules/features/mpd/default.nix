{ self, inputs, ... }: {
  flake.homeModules.mpd = import ./home.nix;
}

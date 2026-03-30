{ self, inputs, ... }: {
  flake.homeModules.yazi = import ./home.nix;
}

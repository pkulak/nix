{ self, inputs, ... }: {
  flake.homeModules.foot = import ./home.nix;
}

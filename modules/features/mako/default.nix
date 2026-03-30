{ self, inputs, ... }: {
  flake.homeModules.mako = import ./home.nix;
}

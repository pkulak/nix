{ self, inputs, ... }: {
  flake.homeModules.jj = import ./home.nix;
}

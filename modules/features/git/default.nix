{ self, inputs, ... }: {
  flake.homeModules.git = import ./home.nix;
}

{ self, inputs, ... }: {
  flake.homeModules.matui = import ./home.nix;
}

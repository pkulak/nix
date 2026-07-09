{ self, inputs, ... }: {
  flake.homeModules.borg = import ./home.nix;
}

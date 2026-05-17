{ self, inputs, ... }: {
  flake.homeModules.swaylock = import ./home.nix;
}

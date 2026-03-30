{ self, inputs, ... }: {
  flake.homeModules.rofi = import ./home.nix;
}

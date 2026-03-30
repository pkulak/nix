{ self, inputs, ... }: {
  flake.homeModules.waybar = import ./home.nix;
}

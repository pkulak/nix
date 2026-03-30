{ self, inputs, ... }: {
  flake.homeModules.firefox = import ./home.nix;
}

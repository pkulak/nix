{ self, inputs, ... }: {
  flake.homeModules.secrets = import ./home.nix;
}

{ self, inputs, ... }: {
  flake.homeModules.intellij = import ./home.nix;
}

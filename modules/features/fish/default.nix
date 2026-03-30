{ self, inputs, ... }: {
  flake.nixosModules.fish = { pkgs, ... }: {
    programs.fish.enable = true;
  };
  flake.homeModules.fish = import ./home.nix;
}

{ self, inputs, ... }: {
  flake.nixosModules.niri = ./nixos.nix;
  flake.homeModules.niri = {
    imports = [
      inputs.niri-flake.homeModules.config
      ./home.nix
    ];
  };
}

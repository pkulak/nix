{ self, ... }: {
  flake.nixosConfigurations.barnaby = self.lib.mkHost {
    host = "barnaby";
    profile = "linux-server";
    nixosModules = [
      self.nixosModules.opencrow
      ./nixos.nix
      ./hardware.nix
    ];
    homeModules = [
      self.homeModules.opencrow
      ./home.nix
    ];
  };
}

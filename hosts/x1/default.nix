{ self, inputs, ... }: {
  flake.nixosConfigurations.x1 = self.lib.mkHost {
    host = "x1";
    profile = "linux-desktop";
    nixosModules = [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
      ./nixos.nix
      ./hardware.nix
    ];
    homeModules = [ ./home.nix ];
  };
}

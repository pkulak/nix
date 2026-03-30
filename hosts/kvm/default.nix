{ self, ... }: {
  flake.nixosConfigurations.kvm = self.lib.mkHost {
    host = "kvm";
    profile = "linux-server";
    nixosModules = [
      ./nixos.nix
      ./hardware.nix
    ];
    homeModules = [ ./home.nix ];
  };
}

{ self, ... }:
{
  flake.nixosConfigurations.fry = self.lib.mkHost {
    host = "fry";
    profile = "linux-desktop";
    nixosModules = [
      self.nixosModules.vm
      self.nixosModules.ollama
      ./nixos.nix
      ./hardware.nix
    ];
    homeModules = [ ./home.nix ];
  };
}

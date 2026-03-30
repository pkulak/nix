{ self, inputs, ... }:
let
  system = "x86_64-linux";
  host = "kvm";

  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  flake.nixosConfigurations.${host} = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit host pkgs-unstable system;
    };

    modules = [
      self.nixosModules.core
      self.nixosModules.home
      self.nixosModules.apps
      self.nixosModules.desktop
      self.nixosModules.system

      ./nixos.nix
      ./hardware.nix
      { home-manager.users.phil.imports = [ ./home.nix ]; }
    ];
  };
}

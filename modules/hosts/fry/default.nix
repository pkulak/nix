{ self, inputs, ... }:
let
  system = "x86_64-linux";
  host = "fry";

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
      inherit (inputs) nixos-hardware nur matui neovim agenix;
    };

    modules = [
      self.nixosModules.core
      self.nixosModules.home
      self.nixosModules.apps
      self.nixosModules.desktop
      self.nixosModules.system
      self.nixosModules.vm
      
      ./nixos.nix
      ./hardware.nix
      
      { home-manager.users.phil.imports = [ ./home.nix self.homeModules.intellij ]; }
    ];
  };
}

{ pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/vm.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t460p
  ];

  environment.systemPackages = [
    pkgs.ideapin.jetbrains.idea-ultimate
  ];

  networking.hostName = "t460p";
  programs.light.enable = true;

  # set up a bridge for VMs
  networking.bridges = {
    vmbr0 = { interfaces = [ "enp0s31f6" ]; };
  };

  networking.interfaces.vmbr0.useDHCP = true;
}

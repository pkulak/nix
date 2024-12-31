{ pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/vm.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t460p
  ];

  environment.systemPackages = [ pkgs.unstable.jetbrains.idea-ultimate ];

  programs.light.enable = true;

  networking = {
    hostName = "t460p";

    # set up a bridge for VMs
    bridges = { vmbr0 = { interfaces = [ "enp0s31f6" ]; }; };

    interfaces.vmbr0.useDHCP = true;
  };
}

{ pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
    ../../common/vm.nix
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  environment.systemPackages = [
    pkgs.jetbrains.idea-ultimate
    pkgs.wdisplays
  ];

  programs.light.enable = true;

  networking = {
    hostName = "x1";

    # set up a bridge for VMs
    bridges = { vmbr0 = { interfaces = [ "wlp2s0" ]; }; };

    interfaces.vmbr0.useDHCP = true;
  };
}

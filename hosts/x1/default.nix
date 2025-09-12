{ pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  environment.systemPackages = [
    pkgs.jetbrains.idea-ultimate
    pkgs.wdisplays
  ];

  programs.light.enable = true;

  networking.hostName = "x1";
}

{ pkgs, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    wdisplays
  ];

  programs.light.enable = true;

  networking.hostName = "x1";
}

{ pkgs, ... }:

{
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
    wdisplays
  ];

  programs.light.enable = true;

  networking.hostName = "x1";
  system.stateVersion = "23.05";
}

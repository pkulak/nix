{ config, pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t460p
  ];

  environment.systemPackages = [
    pkgs.jetbrains.idea-ultimate
  ];

  networking.hostName = "t460p";
  programs.light.enable = true;
}

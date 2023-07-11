{ config, pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t460p
  ];

  networking.hostName = "t460p";
  programs.light.enable = true;
}

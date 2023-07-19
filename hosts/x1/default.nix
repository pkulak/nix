{ config, pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
  ];

  networking.hostName = "x1";
  programs.light.enable = true;
}

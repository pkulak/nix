{ config, pkgs, nixos-hardware, ... }:

{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.apple-macbook-pro-11-5
  ];

  networking.hostName = "macbook";
  programs.light.enable = true;
}

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/vm.nix
  ];

  networking.hostName = "fry";
  boot.initrd.kernelModules = ["amdgpu"];

  environment.systemPackages = [
    pkgs.jetbrains.idea-ultimate
  ];

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "${config.users.users.phil.home}/nix";
    flags = [ "--update-input" "nixpkgs" ];
  };
}

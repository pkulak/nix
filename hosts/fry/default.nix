{ config, pkgs, ... }:
let
  vuescan = (pkgs.callPackage ./vuescan.nix pkgs);
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/vm.nix
  ];

  networking.hostName = "fry";
  # boot.initrd.kernelModules = ["amdgpu"];

  services.udev.packages = [ vuescan ];

  # This will have to change for 23.11:
  # https://nixos.wiki/wiki/Virt-manager
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings

  environment.systemPackages = [
    pkgs.jetbrains.idea-ultimate
    pkgs.virt-manager
    vuescan
  ];

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "${config.users.users.phil.home}/nix";
    flags = [ "--update-input" "nixpkgs" ];
  };
}

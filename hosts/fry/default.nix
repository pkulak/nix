{ config, pkgs, ... }:

let
  vuescan = (pkgs.callPackage ./vuescan.nix pkgs);
in
  {
    imports = [ ./hardware-configuration.nix ];

    networking.hostName = "fry";
    boot.initrd.kernelModules = ["amdgpu"];
    virtualisation.libvirtd.enable = true;
    programs.dconf.enable = true;

    services.udev.packages = [ vuescan ];
    environment.systemPackages = [ pkgs.virt-manager vuescan ];
  }

{ config, pkgs, ... }:

let
  vuescan = (pkgs.callPackage ./vuescan.nix pkgs);
in
  {
    imports = [ ./hardware-configuration.nix ];

    networking.hostName = "fry";
    boot.initrd.kernelModules = ["amdgpu"];

    services.udev.packages = [ vuescan ];
    environment.systemPackages = [ vuescan ];
  }

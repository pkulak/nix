{ config, pkgs, ... }:

let
  vuescan = (pkgs.callPackage ./vuescan.nix pkgs);
in
  {
    imports = [
      ./hardware-configuration.nix
      ../../common/vm.nix
    ];

    networking.hostName = "fry";
    boot.initrd.kernelModules = ["amdgpu"];

    services.udev.packages = [ vuescan ];
    
    environment.systemPackages = [
      pkgs.jetbrains.idea-ultimate
      vuescan
    ];
  }

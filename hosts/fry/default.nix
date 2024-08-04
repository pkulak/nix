{ config, pkgs, ... }:
let
  vuescan = (pkgs.callPackage ./vuescan.nix pkgs);
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/vm.nix
  ];

  networking.hostName = "fry";

  services.udev.packages = [ vuescan ];

  environment.systemPackages = [
    pkgs.ideapin.jetbrains.idea-ultimate
    vuescan
  ];

  system.autoUpgrade = {
    enable = true;
    dates = "02:00";
    randomizedDelaySec = "45min";
    flake = "${config.users.users.phil.home}/nix";
    flags = [
      "--update-input" "nixpkgs-unstable"
      "--update-input" "nur"
    ];
  };
}

{ config, pkgs, ... }:
let vuescan = pkgs.callPackage ./vuescan.nix pkgs;
in {
  imports = [ ./hardware-configuration.nix ../../common/vm.nix ];

  services.udev.packages = [ vuescan ];

  environment.systemPackages =
    [ pkgs.unstable.jetbrains.idea-ultimate vuescan ];

  system.autoUpgrade = {
    enable = true;
    dates = "16:30";
    randomizedDelaySec = "5min";
    flake = "${config.users.users.phil.home}/nix";
    flags = [ "--update-input" "nixpkgs-unstable" "--update-input" "nur" ];
  };

  networking = {
    hostName = "fry";

    # set up a bridge for VMs
    bridges = { vmbr0 = { interfaces = [ "enp37s0" ]; }; };

    interfaces.vmbr0.useDHCP = true;
  };

  fileSystems = {
    "/mnt/storage" = {
      device = "/dev/disk/by-label/Storage";
      fsType = "ext4";
      neededForBoot = false;
      options = ["defaults"];
    };
  };
}

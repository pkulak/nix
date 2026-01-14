{ pkgs, ... }:
let vuescan = pkgs.callPackage ./vuescan.nix pkgs;
in {
  imports = [ ./hardware-configuration.nix ../../common/vm.nix ];

  services.udev.packages = [ vuescan ];

  environment.systemPackages =
    [ pkgs.jetbrains.idea vuescan ];

  networking.hostName = "fry";

  fileSystems = {
    "/mnt/storage" = {
      device = "/dev/disk/by-label/Storage";
      fsType = "ext4";
      neededForBoot = false;
      options = ["defaults"];
    };
  };
}

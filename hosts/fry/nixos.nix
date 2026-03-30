{ pkgs, ... }:
let vuescan = pkgs.callPackage ./vuescan.nix pkgs;
in {
  services.udev.packages = [ vuescan ];

  environment.systemPackages = [ vuescan ];

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

{ config, pkgs, ... }:
let
  vuescan = (pkgs.callPackage ./vuescan.nix pkgs);
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/vm.nix
  ];

  # we have lot's of memory; use it
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  networking.hostName = "fry";

  services.udev.packages = [ vuescan ];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # the firewall screws up Virt-Manger; disable on that interface
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  environment.systemPackages = [
    pkgs.unstable.jetbrains.idea-ultimate
    vuescan
  ];

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "${config.users.users.phil.home}/nix";
    flags = [
      "--update-input" "nixpkgs"
      "--update-input" "nixpkgs-unstable"
      "--update-input" "nur"
      "--update-input" "home-manager"
    ];
  };
}

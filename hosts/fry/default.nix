{ config, pkgs, ... }:
let
  vuescan = (pkgs.callPackage ./vuescan.nix pkgs);
in {
  imports = [
    ./hardware-configuration.nix
    ../../common/vm.nix
  ];

  networking.hostName = "fry";
  boot.initrd.kernelModules = ["amdgpu"];

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

  # Suspend at 5pm at 10pm
  systemd.services.suspend = {
    description = "Suspend the computer.";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "systemctl suspend";
    };
  };

  systemd.timers.suspend = {
    description = "Suspend at 5pm and 10pm";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "*-*-* 17,22:00:00";
    };
  };
}

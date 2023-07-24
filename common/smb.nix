{ config, pkgs, ... }:

let
    automount_opts = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=phil,gid=users,credentials=/home/phil/.ssh/smb-secrets"];
in {
  config = {
    environment.systemPackages = [ pkgs.cifs-utils ];

    fileSystems."/mnt/docker" = {
        device = "//lilnas.home/docker";
        fsType = "cifs";
        options = automount_opts;
    };

    fileSystems."/mnt/music" = {
        device = "//lilnas.home/music";
        fsType = "cifs";
        options = automount_opts;
    };

    fileSystems."/mnt/nas" = {
        device = "//lilnas.home/home";
        fsType = "cifs";
        options = automount_opts;
    };

    fileSystems."/mnt/public" = {
        device = "//lilnas.home/public";
        fsType = "cifs";
        options = automount_opts;
    };

    fileSystems."/mnt/swap" = {
        device = "//lilnas.home/swap";
        fsType = "cifs";
        options = automount_opts;
    };
  };
}

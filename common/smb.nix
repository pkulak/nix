{ config, pkgs, ... }:

let
    automount_opts = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=phil,gid=users,credentials=/run/user/1000/agenix/smb-secrets"];
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

    fileSystems."/mnt/video" = {
        device = "//lilnas.home/video";
        fsType = "cifs";
        options = automount_opts;
    };

    fileSystems."/mnt/photos" = {
        device = "//lilnas.home/photos";
        fsType = "cifs";
        options = automount_opts;
    };
  };
}

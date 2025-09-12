{ config, ... }:

{
  services.mpd = {
    enable = true;
    dataDir = "${config.xdg.dataHome}/mpd";
    musicDirectory = "/mnt/music/";
    extraConfig = ''
      audio_output {
        type    "pipewire"
        name    "pipewire"
      }
      auto_update "no"
      replaygain "auto"
      zeroconf_enabled "no"
    '';
  };

  services.mpd-mpris.enable = true;

  xdg.configFile."rmpc/config.ron".source = ./config.ron;
}

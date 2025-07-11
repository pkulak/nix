{ agenix, config, pkgs, host, system, ... }:

{
  services.mpd = {
    enable = true;
    dataDir = "${config.xdg.dataHome}/mpd";
    musicDirectory = "/mnt/music/";
    network.startWhenNeeded = true;
    extraConfig = ''
      audio_output {
        type    "pipewire"
        name    "pipewire"
      }
      auto_update "yes"
      replaygain "auto"
    '';
  };

  services.mpd-mpris.enable = true;

  xdg.configFile."rmpc/config.ron".source = ./config.ron;
}

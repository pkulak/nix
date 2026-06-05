{ pkgs, ... }:
{
  home.packages = [ pkgs.beets ];

  xdg.configFile."beets/config.yaml".text = ''
    directory: /mnt/music
    pluginpath:
      - ~/.config/beets/plugins
    plugins: fetchart replaygain replaygain_asis musicbrainz

    replaygain:
      backend: ffmpeg

    paths:
      default: $albumartist/$album%aunique{}/$track - $title
      singleton: Non-Album/$artist/$title
      comp: Compilations/$album%aunique{}/$track - $title
  '';

  xdg.configFile."beets/plugins/replaygain_asis.py".source = ./replaygain_asis.py;
}

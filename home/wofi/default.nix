{ config, pkgs, ... }:

{
  xdg.configFile = {
    "wofi/config".text = ''
      width=300
      height=200
      insensitive=true
      mode=drun,run
      columns=1
      padding:5
      lines=6
    '';

    "wofi/style.css".source = ./style.css;
  };
}

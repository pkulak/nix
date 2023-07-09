{ config, pkgs, host, ... }:

{
  imports = [
    ./alacritty.nix
    ./astronvim.nix
    ./hosts/${host}.nix
  ];

  home.username = "phil";
  home.homeDirectory = "/home/phil";

  # Throw the simple stuff straight in here
  xdg.configFile."ranger/rc.conf".text = "map <C-d> shell ${pkgs.xdragon}/bin/dragon -a -x %p";

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}

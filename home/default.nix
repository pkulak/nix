{ config, pkgs, host, ... }:

{
  imports = [
    ./alacritty.nix
    ./astronvim.nix
    ./hosts/${host}.nix
  ];

  home.username = "phil";
  home.homeDirectory = "/home/phil";

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}

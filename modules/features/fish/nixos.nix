{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.phil.shell = pkgs.fish;
}

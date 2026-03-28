
{ pkgs, ... }:

{
  home.file = {
    ".jai/default.conf".source = ./default.conf;
    ".jai/default.jail".source = ./default.jail;
  };
}

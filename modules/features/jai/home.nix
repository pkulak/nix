{ pkgs, ... }:

{
  home.file = {
    ".jai/default.conf".source = ./home/default.conf;
    ".jai/default.jail".source = ./home/default.jail;
    ".jai/pi.jail".source = ./home/pi.jail;
    "agents/AGENTS.md".source = ./home/AGENTS.md;
  };
}

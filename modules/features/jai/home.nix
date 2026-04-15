{ pkgs, ... }:

{
  home.file = {
    ".jai/default.conf".source = ./home/default.conf;
    ".jai/default.jail".source = ./home/default.jail;
    "agents/AGENTS.md".source = ./home/AGENTS.md;
  };
}

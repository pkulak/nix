{ pkgs, ... }:

let
  config = ''
    [user]
      name = "Phil Kulak"
      email = "phil@kulak.us"

    [ui]
      paginate = "auto"
      default-command = ["log", "--no-pager"]
      diff.tool = ["${pkgs.difftastic}/bin/difft", "--color=always", "$left", "$right"]

    [signing]
      sign-all = true
      backend = "ssh"
      key = "/home/phil/.ssh/id_ed25519.pub"

    [revset-aliases]
      all = "latest(all(), 5)"
  '';
in {
  xdg.configFile = {
    "jj/config.toml".text = config;

    "jj/vevo.toml".text =
      builtins.replaceStrings [ "phil@kulak.us" ] [ "phil.kulak@vevo.com" ]
      config;

    "fish/functions/fish_jj_prompt.fish".source = ./prompt.fish;

    "fish/functions/fish_vcs_prompt.fish".text = ''
      function fish_vcs_prompt --description "Print all vcs prompts"
        fish_jj_prompt $argv
        or fish_git_prompt $argv
      end
    '';

    "fish/config.fish".text = ''
      alias pr 'jj git push -c @'
      alias merge "jj bookmark move --from 'trunk()' && jj git push -r @"
      alias fetch 'jj git fetch'

      jj util completion fish | source
    '';
  };

  home.file = {
    "vevo/.envrc".text = ''
      export JJ_CONFIG=~/.config/jj/vevo.toml
    '';
  };
}

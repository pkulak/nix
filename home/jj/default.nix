{ pkgs, ... }:

let
  config = # toml
    ''
      [user]
      name = "Phil Kulak"
      email = "phil@kulak.us"

      [ui]
      paginate = "auto"
      default-command = ["log", "--no-pager"]
      diff-formatter = ["${pkgs.difftastic}/bin/difft", "--color=always", "$left", "$right"]
      diff-editor = ["idea-ultimate", "diff", "$left", "$right"]

      [signing]
      behavior = "own"
      backend = "ssh"
      key = "/home/phil/.ssh/id_ed25519.pub"

      [revset-aliases]
      all = "latest(all(), 16)"

      [git]
      templates.git_push_bookmark = '"phil-" ++ change_id.short()'
    '';
in {
  programs.fish = {
    shellInit = ''
      jj util completion fish | source
    '';

    shellAliases = {
      pr = "jj git push -c @";
      merge = "jj git fetch && jj bookmark move --from 'trunk()' --to @ && jj git push -r @";
      fetch = "jj git fetch";
    };

    functions = {
      fish_jj_prompt.body = builtins.readFile ./prompt.fish;

      fish_vcs_prompt.body = ''
        fish_jj_prompt $argv or fish_git_prompt $argv
      '';
    };
  };

  xdg.configFile = {
    "jj/config.toml".text = config;

    "jj/vevo.toml".text =
      builtins.replaceStrings [ "phil@kulak.us" ] [ "phil.kulak@vevo.com" ]
      config;
  };

  home.file = {
    "vevo/.envrc".text = ''
      export JJ_CONFIG=~/.config/jj/vevo.toml
    '';
  };
}

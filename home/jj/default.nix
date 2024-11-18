_:

{
  xdg.configFile = {
    "jj/config.toml".text = ''
      [user]
        name = "Phil Kulak"
        email = "phil.kulak@vevo.com"

      [ui]
        paginate = "never"
        default-command = "log"

      [signing]
        sign-all = true
        backend = "ssh"
        key = "/home/phil/.ssh/id_ed25519.pub"

      [revset-aliases]
        all = "latest(all(), 5)"
    '';

    "fish/functions/fish_jj_prompt.fish".source = ./prompt.fish;

    "fish/functions/fish_vcs_prompt.fish".text = ''
      function fish_vcs_prompt --description "Print all vcs prompts"
        fish_jj_prompt $argv
        or fish_git_prompt $argv
      end
    '';

    "fish/config.fish".text = ''
      alias pr 'jj git push -c @'
      alias merge 'jj bookmark move --from trunk() && jj git push -r @'

      jj util completion fish | source
    '';
  };
}

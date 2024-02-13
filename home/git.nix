{ config, pkgs, ... }:

{
  xdg.configFile = {
    "git/config".text = ''
      [alias]
        gone = "!f() { git fetch --all --prune; git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D; }; f"

      [commit]
        gpgSign = true

      [diff]
        external = ${pkgs.difftastic}/bin/difft

      [gpg]
        format = ssh

      [gpg "ssh"]
        allowedSignersFile = "~/.ssh/allowed_signers"

      [includeIf "gitdir:~/vevo/"]
        path = ~/.config/git/vevo

      [user]
        name = Phil Kulak
        email = phil@kulak.us
        signingKey = ~/.ssh/id_ed25519.pub
    '';

    "git/vevo".text = ''
      [user]
        email = phil.kulak@vevo.com
    '';
  };
}

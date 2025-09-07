{ pkgs, host, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      fish_vi_key_bindings
      set fish_greeting

      zoxide init fish | source
      direnv hook fish | source
    '';

    shellAliases = {
      l = "lsd -ltr";
      la = "lsd -atr";
      lla = "lsd -latr";
      lt = "lsd --tree";

      last = "ls -t | head -n1";
      clast = "cat (last)";
      vlast = "nvim (last)";
      mlast = "mpv (last)";
      ilast = "imv (last)";
      zlast = "zathura (last)";

      ".." = "cd ..";
      "..." = "cd ../..";
      md = "mkdir -p";
      sm = "smerge .";
      ssh = "TERM=xterm-256color command ssh";
      c = "clear; cd";
      e = "exit";
      vim = "nvim";
      vi = "nvim";
      za = "zathura";
      timestamp = ''date -u +"%Y-%m-%dT%H:%M:%SZ"'';
      bc = "bc -lq";
      rs = "rsync -avH --info=progress2";
      dr = "${pkgs.ripdrag}/bin/ripdrag -a";
      screencast = "${pkgs.wf-recorder}/bin/wf-recorder -g (${pkgs.slurp}/bin/slurp)";
      mnt-private = "mkdir -p ~/private && ${pkgs.gocryptfs}/bin/gocryptfs -noprealloc ~/notes/private ~/private";
      daily = "nvim ~/notes/daily/$(date +%F).md";
      v = "ssh vevo.home";
      jdr = ''jj diff -f "$(current-bookmark)@origin"'';
    };

    functions = {
      dbc = {
        body = ''
          mkdir -p /home/phil/homes/$argv
          distrobox create --name $argv --image debian:latest --home /home/phil/homes/$argv
        '';
        wraps = "distrobox";
      };

      compress.body = ''
        tar -czf (basename $argv).tar.gz $argv
      '';

      extract.body = ''
        tar -xvf $argv
      '';

      current-bookmark.body = ''
        jj bookmark list --tracked -r 'trunk()..@' -T 'name++"\n"' | head -1
      '';

      tail-daily.body = ''
        set cutoff (date -d "-30 day" -u +"%Y-%m-%d.md")

        for f in ~/notes/daily/*
          set file (basename $f)

          if expr "$file" \> "$cutoff" >/dev/null
            echo "# $file"
            echo
            cat $f
            echo
          end
        end
      '';
    };
  };
}

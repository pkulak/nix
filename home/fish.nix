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
      y = "yazi";
      timestamp = ''date -u +"%Y-%m-%dT%H:%M:%SZ"'';
      bc = "bc -lq";
      rs = "rsync -avH --info=progress2";
      dr = "${pkgs.ripdrag}/bin/ripdrag -a";
      screencast = "${pkgs.wf-recorder}/bin/wf-recorder -g (${pkgs.slurp}/bin/slurp)";
      mnt-private = "mkdir -p ~/private && ${pkgs.gocryptfs}/bin/gocryptfs -noprealloc ~/notes/private ~/private";
      daily = "nvim ~/notes/daily/$(date +%F).md";
      v = "ssh vevo.home";
      tsv = "sudo tailscale switch vevo.com && sudo tailscale up --accept-routes --hostname phil-${host}";
      tsd = "sudo tailscale down";
      tss = "sudo tailscale status";
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

      basename_no_ext.body = ''
        string replace -r '\.[^.]*$' "" $argv[1]
      '';

      transcode.body = ''
        ${pkgs.ffmpeg}/bin/ffmpeg -i $argv[1] -vf scale=1920:1080 -c:v libx264 -preset veryslow -crf 23 -c:a copy (basename_no_ext $argv[1])-1080p.mp4
      '';

      img2jpg.body = ''
        ${pkgs.imagemagick}/bin/magick $argv[1] -quality 90 -strip (basename_no_ext $argv[1]).jpg
      '';

      img2jpg-small.body = ''
        ${pkgs.imagemagick}/bin/magick $argv[1] -resize 1440x\> -quality 90 -strip (basename_no_ext $argv[1]).jpg
      '';

      img2png.body = ''
        ${pkgs.imagemagick}/bin/magick $argv[1] -strip -define png:compression-filter=5 \
          -define png:compression-level=9 \
          -define png:compression-strategy=1 \
          -define png:exclude-chunk=all \
          (basename_no_ext $argv[1]).png
      '';

      dkillall.body = ''
        set containers (docker ps -q)
        if test (count $containers) -gt 0
          docker kill $containers
        end
      '';

      dup = {
        body = ''
          dkillall && docker compose up $argv
        '';
        wraps = "docker compose up";
      };
    };
  };
}

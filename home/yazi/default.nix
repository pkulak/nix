{pkgs, ...}: let
  yazi-filechooser = pkgs.writeShellApplication {
    name = "yazi-filechooser";

    runtimeInputs = with pkgs; [
      yazi
      ghostty
    ];

    text = builtins.readFile ./yazi-filechooser.sh;
  };
in {
  xdg.configFile = {
    "xdg-desktop-portal-termfilechooser/config" = {
      enable = true;
      text = ''
        [filechooser]
        cmd=${yazi-filechooser}/bin/yazi-filechooser
        default_dir=$HOME/Screenshots
        open_mode=suggested
        save_mode=last
      '';
    };

    "yazi/keymap.toml".text = # toml
      ''
        [mgr]
        prepend_keymap = [
          # replace the delete binds with double presses
          { on = "d", run = "noop" },
          { on = "D", run = "noop" },
          { on = ["d", "d"], run = "remove", desc = "Trash selected files" },
          { on = ["d", "m"], run = 'shell "umount $@"', desc = "Unmount" },
	        { on = ["d", "D"], run = "remove --permanently", desc = "Permanently delete selected files" },

          # use RipDrag
          { on = ["d", "r"], run = 'shell "${pkgs.ripdrag}/bin/ripdrag -a $@"', desc = "Drag and drop selected files" },

          # use Oil bindings
          { on = "<Enter>", run = "enter", desc = "Enter the child directory." },
          { on = "-", run = "leave", desc = "Back to the parent directory." },

          # more Vim-like than <C-s>
          { on = "<C-l>", run = "escape --search", desc = "Cancel the ongoing search" },

          # prefer Zoxide
          { on = "z", run = "plugin zoxide", desc = "Jump to a file/directory via zoxide" },
          { on = "Z", run = "plugin fzf", desc = "Jump to a file/directory via zoxide" },
          
          # bookmarks
          { on = [ "g", "s" ], run = "cd ~/Screenshots", desc = "Go ~/Screenshots" },
          { on = [ "g", "m" ], run = "cd /mnt", desc = "Go /mnt" },
        ]
      '';

    "yazi/yazi.toml".text = # toml
      ''
        [mgr]
        sort_by = "mtime"
        sort_reverse = true
        sort_dir_first = true
        ratio = [0, 5, 7]
      '';

    "yazi/theme.toml".source = ./theme.toml;
  };
}

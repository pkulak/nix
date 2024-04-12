{
  plugins.telescope = {
    enable = true;

    keymaps = {
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Live Grep";
      };

      "<leader>ff" = {
        action = "find_files";
        options.desc = "Open File";
      };

      "<leader>b" = {
        action = "buffers";
        options.desc = "Open Buffer";
      };
    };

    settings.defaults = {
      file_ignore_patterns = [
        "^.git/"
        "^.mypy_cache/"
        "^__pycache__/"
        "^build/"
        "^out/"
        "^data/"
        "%.ipynb"
      ];

      set_env.COLORTERM = "truecolor";
    };
  };
}

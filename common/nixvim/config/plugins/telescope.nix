{
  plugins.telescope = {
    enable = true;

    keymaps = {
      "<leader>fg" = {
        action = "live_grep";
        desc = "Live Grep";
      };

      "<leader>ff" = {
        action = "find_files";
        desc = "Open File";
      };

      "<leader>b" = {
        action = "buffers";
        desc = "Open Buffer";
      };
    };

    defaults = {
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

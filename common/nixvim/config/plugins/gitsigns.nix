{
  plugins.gitsigns = {
    enable = true;

    settings = {
      trouble = true;
      current_line_blame = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>gd";
      action = ":Gitsigns diffthis<CR>";
      options = {
        silent = true;
        desc = "Diff This";
      };
    }
    {
      mode = "n";
      key = "<leader>gR";
      action = ":Gitsigns reset_buffer<CR>";
      options = {
        silent = true;
        desc = "Reset Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>gr";
      action = ":Gitsigns reset_hunk<CR>";
      options = {
        silent = true;
        desc = "Reset Hunk";
      };
    }
    {
      mode = "n";
      key = "<leader>gS";
      action = ":Gitsigns stage_buffer<CR>";
      options = {
        silent = true;
        desc = "Stage Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = ":Gitsigns stage_hunk<CR>";
      options = {
        silent = true;
        desc = "Stage Hunk";
      };
    }
  ];
}

{
  plugins.gitsigns = {
    enable = true;

    trouble = true;
    currentLineBlame = true;

    signs = {
      add = { text = "│"; };
      change = { text = "│"; };
      delete = { text = "_"; };
      topdelete = { text = "‾"; };
      changedelete = { text = "~"; };
      untracked = { text = "│"; };
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
      key = "<leader>gS";
      action = ":Gitsigns stage_buffer<CR>";
      options = {
        silent = true;
        desc = "Stage Buffer";
      };
    }
  ];
}

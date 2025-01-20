{
  plugins.barbar = { enable = true; };

  keymaps = [
    {
      mode = "n";
      key = "<leader>bc";
      action = "<Cmd>BufferClose<CR>";
      options = {
        silent = true;
        desc = "Close Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>bC";
      action = "<Cmd>BufferCloseAllButCurrent<CR>";
      options = {
        silent = true;
        desc = "Close Buffer All But Current";
      };
    }
    {
      mode = "n";
      key = "<leader>bp";
      action = "<Cmd>BufferPick<CR>";
      options = {
        silent = true;
        desc = "Pick Buffer";
      };
    }
    {
      mode = "n";
      key = "<leader>bP";
      action = "<Cmd>BufferPickDelete<CR>";
      options = {
        silent = true;
        desc = "Pick Buffer and Delete";
      };
    }
  ];
}

{
  plugins.neo-tree = {
    enable = true;
    closeIfLastWindow = true;

    window = {
      width = 30;
      autoExpandWidth = true;
    };

    extraOptions = {
      group_extra_dirs = true;
      scan_mode = "deep";
    };
  };

  keymaps = [
    {
      key = "<leader>e";
      options.silent = true;
      action = ":Neotree toggle reveal<CR>";
      options.desc = "Open Neo-tree";
    }
    {
      key = "<leader>r";
      options.silent = true;
      action = ":Neotree reveal<CR>";
      options.desc = "Reveal File in Neo-tree";
    }
  ];
}

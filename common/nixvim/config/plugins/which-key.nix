{
  plugins.which-key = {
    enable = true;

    settings.spec = [
      {
        __unkeyed-1 = "<leader>f";
        desc = "Telescope";
      }
      {
        __unkeyed-1 = "<leader>g";
        desc = "Git Signs";
      }
    ];
  };

  plugins.mini = {
    enable = true;

    modules = {
      icons = {};
    };
  };
}

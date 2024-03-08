{ pkgs, ... }: {
  # Import all your configuration modules here
  imports = [
    ./catppuccin.nix
    ./plugins/barbar.nix
    ./plugins/gitsigns.nix
    ./plugins/lsp.nix
    ./plugins/lualine.nix
    ./plugins/neo-tree.nix
    ./plugins/telescope.nix
    ./plugins/tmux-navigator.nix
    ./plugins/which-key.nix
  ];

  config = {
    globals = {
      mapleader = " ";
      loaded_netrw = 0;
      loaded_netrwPlugin = 0;
    };

    options = {
      number = true;
      relativenumber = true;
      showmode = false;
      wrap = false;
      mouse = "a";
      swapfile = false;
      undofile = true;

      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      autoindent = true;

      incsearch = true;
      inccommand = "split";
      ignorecase = true;
      smartcase = true;

      scrolloff = 8;

      fileencoding = "utf-8";
      termguicolors = true;
    };

    keymaps = [
      {
        key = "=j";
        options.silent = true;
        action = ":%!${pkgs.jq}/bin/jq<CR>:set syntax=json<CR>";
        options.desc = "Format as JSON";
      }
      {
        key = "=x";
        options.silent = true;
        action =
          ":%!${pkgs.libxml2}/bin/xmllint --format -<CR>:set syntax=xml<CR>";
        options.desc = "Format as XML";
      }
      {
        key = "=s";
        options.silent = true;
        action = ":%sort<CR>";
        options.desc = "Sort";
      }
      {
        key = "<esc>";
        action = ":noh<CR>";
        options.silent = true;
      }
    ];
  };
}

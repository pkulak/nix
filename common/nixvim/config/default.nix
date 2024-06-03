{ pkgs, ... }: {
  # Import all your configuration modules here
  imports = [
    ./catppuccin.nix
    ./plugins/barbar.nix
    ./plugins/comment.nix
    ./plugins/gitsigns.nix
    ./plugins/lsp.nix
    ./plugins/lualine.nix
    ./plugins/neo-tree.nix
    ./plugins/telescope.nix
    ./plugins/tmux-navigator.nix
    ./plugins/treesitter.nix
    ./plugins/trouble.nix
    ./plugins/which-key.nix
  ];

  config = {
    globals = {
      mapleader = " ";
      loaded_netrw = 0;
      loaded_netrwPlugin = 0;
    };

    opts = {
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
      {
        key = "jj";
        action = "<Esc>";
        mode = "i";
      }
      {
        key = "jx";
        action = "<Esc>:x<CR>";
        mode = "i";
      }

      # BarBar
      {
        key = "<A-,>";
        options.silent = true;
        action = "<Cmd>BufferPrevious<CR>";
      }
      {
        key = "<A-.>";
        options.silent = true;
        action = "<Cmd>BufferNext<CR>";
      }
      {
        key = "<A-p>";
        options.silent = true;
        action = "<Cmd>BufferPick<CR>";
      }
      {
        key = "<A-d>";
        options.silent = true;
        action = "<Cmd>BufferPickDelete<CR>";
      }
      {
        key = "<A-w>";
        options.silent = true;
        action = "<Cmd>BufferClose<CR>";
      }
      {
        key = "<A-W>";
        options.silent = true;
        action = "<Cmd>BufferWipeout<CR>";
      }
      {
        key = "<A-0>";
        options.silent = true;
        action = "<Cmd>BufferLast<CR>";
      }

      # Wipe out the arrow keys
      {
        key = "<Up>";
        options.silent = true;
        action = "<Nop>";
      }
      {
        key = "<Down>";
        options.silent = true;
        action = "<Nop>";
      }
      {
        key = "<Left>";
        options.silent = true;
        action = "<Nop>";
      }
      {
        key = "<Right>";
        options.silent = true;
        action = "<Nop>";
      }
    ];
  };
}

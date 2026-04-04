{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  config.settings.config_directory = ./.;

  config.specs.colorscheme = {
    lazy = false;
    data = pkgs.vimPlugins.catppuccin-nvim;
  };

  config.specs.lze = with pkgs.vimPlugins; [
    lze
    {
      data = lzextras;
      name = "lzextras";
    }
  ];

  config.specs.nix = {
    data = null;
    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];
  };

  config.specs.lua = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    extraPackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.prose = {
    after = [ "general" ];
    lazy = true;
    data = null;
    extraPackages = with pkgs; [
      harper
    ];
  };

  config.specs.rust = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      rustaceanvim
    ];
    extraPackages = with pkgs; [
      rust-analyzer
      rustfmt
    ];
  };

  config.specs.general = {
    after = [ "lze" ];
    lazy = true;
    extraPackages = with pkgs; [
      tree-sitter
      jq
      libxml2
    ];
    data = with pkgs.vimPlugins; [
      {
        data = vim-sleuth;
        lazy = false;
      }
      better-escape-nvim
      snacks-nvim
      oil-nvim
      nvim-lspconfig
      nvim-surround
      vim-startuptime
      blink-cmp
      blink-compat
      cmp-cmdline
      colorful-menu-nvim
      lualine-nvim
      gitsigns-nvim
      which-key-nvim
      fidget-nvim
      nvim-lint
      conform-nvim
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
    ];
  };

  config.specMods =
    {
      parentSpec ? null,
      parentOpts ? null,
      parentName ? null,
      config,
      ...
    }:
    {
      options.extraPackages = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
        description = "packages to suffix to the PATH";
      };
    };
  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

  # expose spec enable/disable state to lua: nixInfo(false, "settings", "cats", "rust")
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };
}

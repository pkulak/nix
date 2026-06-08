{
  config,
  wlib,
  lib,
  pkgs,
  options,
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
    runtimePkgs = with pkgs; [
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
    runtimePkgs = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.prose = {
    after = [ "general" ];
    lazy = true;
    data = null;
    runtimePkgs = with pkgs; [
      harper
    ];
  };

  config.specs.rust = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      rustaceanvim
    ];
    runtimePkgs = with pkgs; [
      rust-analyzer
      rustfmt
    ];
  };

  config.specs.go = {
    after = [ "general" ];
    lazy = true;
    data = null;
    runtimePkgs = with pkgs; [
      gopls
      gotools
    ];
  };

  config.specs.general = {
    after = [ "lze" ];
    lazy = true;
    runtimePkgs = with pkgs; [
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

  config.specMods = {
    options.runtimePkgs = options.runtimePkgs // {
      description = "packages to suffix to the PATH";
    };
  };
  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

  # expose spec enable/disable state to lua: nixInfo(false, "settings", "cats", "rust")
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };
}

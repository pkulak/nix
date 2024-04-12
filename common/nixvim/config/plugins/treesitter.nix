{
  plugins.treesitter = {
    enable = true;

    nixvimInjections = true;

    folding = false;
    indent = true;
  };

  plugins.treesitter-refactor = {
    enable = true;
    highlightDefinitions.enable = true;
  };

  plugins.hmts.enable = true;
}

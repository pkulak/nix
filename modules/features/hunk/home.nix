{ ... }:
{
  programs.hunk = {
    enable = true;
    enableJujutsuIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      mode = "stacked";
      line_numbers = true;
    };
  };
}

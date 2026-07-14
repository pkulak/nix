{ ... }:
{
  programs.hunk = {
    enable = true;
    enableJujutsuIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      mode = "split";
      line_numbers = true;
    };
  };
}

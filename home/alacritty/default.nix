{ pkgs, ... }:

{
  programs.alacritty.enable = true;

  programs.alacritty.settings = {
    import = [
      "${./catppuccin-mocha.toml}"
    ];

    keyboard.bindings = [
      { key = "V"; mods = "Control"; action = "Paste"; }
      { key = "C"; mods = "Control"; action = "Copy"; }
      { key = "V"; mods = "Control|Shift"; chars = "\\u0016"; }
      { key = "C"; mods = "Control|Shift"; chars = "\\u0003"; }
    ];

    window = {
      padding = { x = 2; y = 2; };
      dimensions = {
        columns = 112;
        lines = 32;
      };
    };

    font = {
      normal.family = "FantasqueSansM Nerd Font Mono";
      bold.family = "FantasqueSansM Nerd Font Mono";
      italic.family = "FantasqueSansM Nerd Font Mono";
      size = pkgs.lib.mkDefault 13;
    };
  };
}

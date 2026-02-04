{ pkgs, config, ... }:

{
  programs.rofi = {
    enable = true;

    theme = "${config.home.homeDirectory}/.config/rofi/catppucin-mocha.rasi";

    plugins = with pkgs; [ rofi-calc rofi-emoji ];

    extraConfig = {
      modi = "drun,calc,emoji";
      show-icons = true;
      terminal = "ghostty +new-window";
      drun-display-format = "{icon} {name}";
      disable-history = false;
      hide-scrollbar = true;
      sidebar-mode = true;
      display-drun = "   Apps ";
      display-calc = " 🧮 Calculator ";
      display-emoji = " 🤨 Emoji ";
    };
  };

  xdg.configFile."rofi/catppucin-mocha.rasi".source = ./catppuccin-mocha.rasi;
}

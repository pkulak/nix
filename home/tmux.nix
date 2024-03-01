{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    historyLimit = 100000;

    plugins = with pkgs;
      [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = '' 
            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_tabs_enabled on
            set -g @catppuccin_date_time "%H:%M"
          '';
        }
        tmuxPlugins.fzf-tmux-url
        tmuxPlugins.sensible
        tmuxPlugins.yank
      ];
    extraConfig = ''
      set -g mouse on

      # full color
      set -g default-terminal "alacritty" 
      set-option -sa terminal-overrides ",alacritty*:Tc"

      # index windows starting at 1
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # easily create new sessions
      bind S command-prompt -p "New Session:" "new-session -A -s '%%'"
      bind K confirm kill-session

      # Use vim keybindings in copy mode
      set-window-option -g mode-keys vi

      # v in copy mode starts making selection
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Escape turns on copy mode
      bind Escape copy-mode

      # Fast window switching and creating
      bind -n C-n select-window -n
      bind -n C-p select-window -p
    '';
  };
}


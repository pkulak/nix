{ pkgs, ... }:
let
  edit-buffer = pkgs.writeShellApplication {
    name = "edit-buffer";
    text = ''
      file=$(mktemp)
      tmux capture-pane -pS -1024 > "$file"
      tmux new-window -n:edit "nvim '+ normal G $' $file"
    '';
  };
in {
  home.packages = with pkgs; [
    fzf
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "foot";
    historyLimit = 100000;

    plugins = with pkgs;
      [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = '' 
            set -g @catppuccin_flavor 'mocha'

            # Make the status line pretty and add some modules
            set -g status-right-length 100
            set -g status-left-length 100
            set -g status-left ""
            set -g status-right "#{E:@catppuccin_status_application}"
            set -ag status-right "#{E:@catppuccin_status_session}"
            set -ag status-right "#{E:@catppuccin_status_uptime}"
          '';
        }
        tmuxPlugins.sensible
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.yank
      ];
    extraConfig = ''
      set -g mouse on

      # index windows starting at 1
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      set -g renumber-windows on

      # better splits
      unbind %
      bind-key - split-window -v
      unbind '"'
      bind-key | split-window -h

      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r h resize-pane -L 5
      bind -r m resize-pane -Z

      bind c new-window -c "#{pane_current_path}"

      # easily create/rename new sessions
      bind S command-prompt -p "New Session:" "new-session -A -s '%%'"
      bind K confirm kill-session

      bind r command-prompt -p "New Name:" "rename-session '%%'"

      # swap to and from the global session
      bind C-b run-shell "tmux switch -t $(get-tag-name)"
      bind g new-session -A -s global

      # Fast window switching and creating
      bind -n C-n select-window -n
      bind -n C-p select-window -p

      # Copy/Paste
      setw -g mode-keys vi
      bind -T copy-mode-vi Y send -X copy-end-of-line-and-cancel "wl-copy"
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"

      # Edit buffer in Vim
      bind-key e run-shell "${edit-buffer}/bin/edit-buffer"
    '';
  };
}


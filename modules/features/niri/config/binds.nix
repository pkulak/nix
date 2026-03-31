{ config }:

with config.lib.niri.actions;

{
  binds = {
    "Mod+Shift+Slash".action = show-hotkey-overlay;

    "Mod+Return" = {
      hotkey-overlay.title = "Open a Terminal: ghostty";
      action = spawn-sh "ghostty +new-window";
    };
    "Mod+P" = {
      hotkey-overlay.title = "Open a Browser: firefox";
      action = spawn "firefox";
    };
    "Mod+D" = {
      hotkey-overlay.title = "Run an Application: rofi";
      action = spawn-sh "rofi -wayland -show drun";
    };
    "Mod+E" = {
      hotkey-overlay.title = "Browse Emojis";
      action = spawn-sh "rofi -wayland -show emoji";
    };
    "Mod+Z" = {
      hotkey-overlay.title = "Calculator";
      action = spawn-sh "rofi -wayland -modi calc -show calc -no-show-match -no-sort -terse";
    };
    "Mod+X" = {
      hotkey-overlay.title = "Power Options";
      action = spawn "rofi-power";
    };
    "Mod+S" = {
      hotkey-overlay.title = "Audio Output Toggle";
      action = spawn "switch-audio";
    };
    "Ctrl+Space" = {
      hotkey-overlay.title = "Dismiss Notification";
      action = spawn-sh "makoctl dismiss";
    };
    "Ctrl+Shift+Space" = {
      hotkey-overlay.title = "Dismiss All Notifications";
      action = spawn-sh "makoctl dismiss --all";
    };

    "XF86AudioRaiseVolume" = {
      allow-when-locked = true;
      action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
    };
    "XF86AudioLowerVolume" = {
      allow-when-locked = true;
      action = spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
    };
    "XF86AudioMute" = {
      allow-when-locked = true;
      action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };
    "XF86AudioMicMute" = {
      allow-when-locked = true;
      action = spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    };

    "XF86AudioPlay" = { allow-when-locked = true; action = spawn-sh "playerctl play-pause"; };
    "XF86AudioStop" = { allow-when-locked = true; action = spawn-sh "playerctl stop"; };
    "XF86AudioPrev" = { allow-when-locked = true; action = spawn-sh "playerctl previous"; };
    "XF86AudioNext" = { allow-when-locked = true; action = spawn-sh "playerctl next"; };

    "Prior" = { allow-when-locked = true; action = spawn-sh "playerctl play-pause"; };
    "Next"  = { allow-when-locked = true; action = spawn-sh "playerctl next"; };

    "XF86MonBrightnessUp" = {
      allow-when-locked = true;
      action = spawn ["brightnessctl" "--class=backlight" "set" "+10%"];
    };
    "XF86MonBrightnessDown" = {
      allow-when-locked = true;
      action = spawn ["brightnessctl" "--class=backlight" "set" "10%-"];
    };

    "Mod+O" = { repeat = false; action = toggle-overview; };
    "Mod+W" = { repeat = false; action = close-window; };

    "Mod+Left".action  = focus-column-left;
    "Mod+Down".action  = focus-window-or-workspace-down;
    "Mod+Up".action    = focus-window-or-workspace-up;
    "Mod+Right".action = focus-column-right;
    "Mod+H".action     = focus-column-left;
    "Mod+J".action     = focus-window-down-or-top;
    "Mod+K".action     = focus-window-up-or-bottom;
    "Mod+L".action     = focus-column-right;

    "Mod+Shift+Left".action  = move-column-left;
    "Mod+Shift+Down".action  = move-window-down-or-to-workspace-down;
    "Mod+Shift+Up".action    = move-window-up-or-to-workspace-up;
    "Mod+Shift+Right".action = move-column-right;
    "Mod+Shift+H".action     = move-column-left;
    "Mod+Shift+J".action     = move-window-down-or-to-workspace-down;
    "Mod+Shift+K".action     = move-window-up-or-to-workspace-up;
    "Mod+Shift+L".action     = move-column-right;

    "Mod+Home".action     = focus-column-first;
    "Mod+End".action      = focus-column-last;
    "Mod+Ctrl+Home".action = move-column-to-first;
    "Mod+Ctrl+End".action  = move-column-to-last;

    "Mod+Ctrl+Left".action  = focus-monitor-left;
    "Mod+Ctrl+Down".action  = focus-monitor-down;
    "Mod+Ctrl+Up".action    = focus-monitor-up;
    "Mod+Ctrl+Right".action = focus-monitor-right;
    "Mod+Ctrl+H".action     = focus-monitor-left;
    "Mod+Ctrl+J".action     = focus-monitor-down;
    "Mod+Ctrl+K".action     = focus-monitor-up;
    "Mod+Ctrl+L".action     = focus-monitor-right;

    "Mod+Shift+Ctrl+Left".action  = move-column-to-monitor-left;
    "Mod+Shift+Ctrl+Down".action  = move-column-to-monitor-down;
    "Mod+Shift+Ctrl+Up".action    = move-column-to-monitor-up;
    "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
    "Mod+Shift+Ctrl+H".action     = move-column-to-monitor-left;
    "Mod+Shift+Ctrl+J".action     = move-column-to-monitor-down;
    "Mod+Shift+Ctrl+K".action     = move-column-to-monitor-up;
    "Mod+Shift+Ctrl+L".action     = move-column-to-monitor-right;

    "Mod+Page_Down".action      = focus-workspace-down;
    "Mod+Page_Up".action        = focus-workspace-up;
    "Mod+U".action              = focus-workspace-down;
    "Mod+I".action              = focus-workspace-up;
    "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
    "Mod+Ctrl+Page_Up".action   = move-column-to-workspace-up;
    "Mod+Ctrl+U".action         = move-column-to-workspace-down;
    "Mod+Ctrl+I".action         = move-column-to-workspace-up;

    "Mod+Shift+Page_Down".action = move-workspace-down;
    "Mod+Shift+Page_Up".action   = move-workspace-up;
    "Mod+Shift+U".action         = move-workspace-down;
    "Mod+Shift+I".action         = move-workspace-up;

    "Mod+WheelScrollDown"      = { cooldown-ms = 150; action = focus-workspace-down; };
    "Mod+WheelScrollUp"        = { cooldown-ms = 150; action = focus-workspace-up; };
    "Mod+Ctrl+WheelScrollDown" = { cooldown-ms = 150; action = move-column-to-workspace-down; };
    "Mod+Ctrl+WheelScrollUp"   = { cooldown-ms = 150; action = move-column-to-workspace-up; };

    "Mod+WheelScrollRight".action      = focus-column-right;
    "Mod+WheelScrollLeft".action       = focus-column-left;
    "Mod+Ctrl+WheelScrollRight".action = move-column-right;
    "Mod+Ctrl+WheelScrollLeft".action  = move-column-left;

    "Mod+Shift+WheelScrollDown".action      = focus-column-right;
    "Mod+Shift+WheelScrollUp".action        = focus-column-left;
    "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-right;
    "Mod+Ctrl+Shift+WheelScrollUp".action   = move-column-left;

    "Mod+1".action = focus-workspace 1;
    "Mod+V".action = focus-workspace "vevo";
    "Mod+2".action = focus-workspace 2;
    "Mod+3".action = focus-workspace 3;
    "Mod+4".action = focus-workspace 4;
    "Mod+5".action = focus-workspace 5;
    "Mod+6".action = focus-workspace 6;
    "Mod+7".action = focus-workspace 7;
    "Mod+8".action = focus-workspace 8;
    "Mod+9".action = focus-workspace 9;

    "Mod+Shift+1".action.move-column-to-workspace = 1;
    "Mod+Shift+V".action.move-column-to-workspace = "vevo";
    "Mod+Shift+2".action.move-column-to-workspace = 2;
    "Mod+Shift+3".action.move-column-to-workspace = 3;
    "Mod+Shift+4".action.move-column-to-workspace = 4;
    "Mod+Shift+5".action.move-column-to-workspace = 5;
    "Mod+Shift+6".action.move-column-to-workspace = 6;
    "Mod+Shift+7".action.move-column-to-workspace = 7;
    "Mod+Shift+8".action.move-column-to-workspace = 8;
    "Mod+Shift+9".action.move-column-to-workspace = 9;

    "Mod+BracketLeft".action  = consume-or-expel-window-left;
    "Mod+BracketRight".action = consume-or-expel-window-right;
    "Mod+Comma".action        = consume-window-into-column;
    "Mod+Period".action       = expel-window-from-column;

    "Mod+R".action        = switch-preset-column-width;
    "Mod+Shift+R".action  = switch-preset-window-height-back;
    "Mod+Ctrl+R".action   = reset-window-height;
    "Mod+F".action        = maximize-column;
    "Mod+Shift+F".action  = fullscreen-window;
    "Mod+M".action        = maximize-window-to-edges;
    "Mod+Ctrl+F".action   = expand-column-to-available-width;
    "Mod+C".action        = center-column;
    "Mod+Shift+C".action  = center-visible-columns;

    "Mod+Minus".action       = set-column-width "-5%";
    "Mod+Equal".action       = set-column-width "+5%";
    "Mod+Shift+Minus".action = set-window-height "-5%";
    "Mod+Shift+Equal".action = set-window-height "+5%";

    "Mod+Space".action       = toggle-window-floating;
    "Mod+Shift+Space".action = switch-focus-between-floating-and-tiling;

    "Mod+Q".action = toggle-column-tabbed-display;

    # screenshot actions are not in lib.niri.actions; use plain attribute style
    "Print".action.screenshot        = {};
    "Mod+Shift+S".action.screenshot  = {};
    "Ctrl+Print".action.screenshot-screen = {};
    "Alt+Print".action.screenshot-window  = {};

    "Mod+Escape" = { allow-inhibiting = false; action = toggle-keyboard-shortcuts-inhibit; };

    "Mod+Shift+E".action    = quit;
    "Ctrl+Alt+Delete".action = quit;

    "Mod+Shift+P".action = power-off-monitors;

    "Mod+Alt+W".action = set-dynamic-cast-window;
    "Mod+Alt+M".action = set-dynamic-cast-monitor;
    "Mod+Alt+X".action = clear-dynamic-cast-target;
    "Mod+Alt+F".action = toggle-windowed-fullscreen;
  };
}

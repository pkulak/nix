{ config, pkgs, ... }:

let
  wofi-power = pkgs.stdenv.mkDerivation {
    name = "wofi-power";
    nativeBuildInputs = with pkgs; [ makeWrapper ];
    dontUnpack = true;

    installPhase = ''
      makeWrapper ${./wofi-power} $out/bin/wofi-power \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.wofi ]}
    '';
  };

  wofi-emoji = pkgs.stdenv.mkDerivation {
    name = "wofi-emoji";
    nativeBuildInputs = with pkgs; [ makeWrapper ];
    dontUnpack = true;

    installPhase = ''
      makeWrapper ${./wofi-emoji} $out/bin/wofi-emoji \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.wofi ]}
    '';
  };
in {
  wayland.windowManager.hyprland = {
    settings = {
      bind = [
        # Terminal
        "$mod, RETURN, exec, alacritty -e fish"
        "$mod SHIFT, RETURN, exec, alacritty --class floating -e fish"

        # Apps / Utils
        "$mod, P, exec, firefox"
        "$mod, N, exec, nemo"
        "$mod, E, exec, ${wofi-emoji}/bin/wofi-emoji"
        "$mod, X, exec, ${wofi-power}/bin/wofi-power"
        "$mod, D, exec, wofi -a -b -I -modi drun --show drun"
        "$mod SHIFT, C, exec, mkdir -p $HOME/Screenshots && slurp | grim -g - $HOME/Screenshots/$(date +'%Y-%m-%d-%H%M%S.png')"

        # Commands
        "$mod, W, killactive,"
        "$mod SHIFT, space, togglefloating,"
        "$mod, F, fullscreen, 1"
        "$mod SHIFT, F, fullscreen, 0"
        "$mod CTRL, F, fakefullscreen"

        # Master stack
        "$mod, M, layoutmsg, swapwithmaster"
        "$mod SHIFT, left, layoutmsg, orientationleft"
        "$mod SHIFT, right, layoutmsg, orientationright"

        # Groups (tabbed windows)
        "$mod, T, togglegroup"
        "$mod CTRL, left, changegroupactive, b"
        "$mod CTRL, right, changegroupactive, f"
        "$mod SHIFT, T, lockgroups, toggle"

        # Move focus with mod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Switch workspaces with mod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scratchpad
        "$mod, S, togglespecialworkspace, scratch"
        "$mod SHIFT, S, movetoworkspace, special:scratch"

        # Media control
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPrev, exec, playerctl previous"

        # Mako
        "CTRL, SPACE, exec, makoctl dismiss"
      ];

      bindm = [
        # Move/resize windows with mod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };

    extraConfig = ''
      bind=$mod,R,submap,resize

      submap=resize

      binde=,right,resizeactive,15 0
      binde=,left,resizeactive,-15 0
      binde=,up,resizeactive,0 -15
      binde=,down,resizeactive,0 15

      bind=,escape,submap,reset
      bind=,return,submap,reset

      submap=reset
    '';
  };
}

{ config, inputs, pkgs, ... }:
{
  imports =
  [
    ./desktop.nix
  ];

  home.packages = with pkgs; [
      rofi
      kitty
      grim
      slurp
      wl-clipboard
      cliphist
      brightnessctl
      pavucontrol
      networkmanagerapplet
      blueman
      crystal-dock
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwatia-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwatia-dark";
      button-layout = "appmenu:";
    };
  };

  programs.waybar.enable = true;
  programs.waybar.settings = {
    mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        margin = "6px 6px 0px 6px";
        output = [
        "eDP-1"
        "HDMI-A-1"
        ];
        modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "wlr/taskbar" "hyprland/window" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "clock" "tray" ];

        "hyprland/workspaces" = {
            all-outputs = true;
            format = "{name}";
            on-click = "activate";
            sort-by-number = true;
        };
        
        "wlr/taskbar" = {
            icon-size = 18;
            on-click = "activate";
            on-click-middle = "close";
            tooltip = true;
        };

        "hyprland/window" = {
            max-length = 50;
            format = "{}";
        };

        "clock" = {
            format = "{:%H:%M}";
            format-alt = "{:%Y-%m-%d %H:%M:%S}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
            format = "CPU {usage}%";
            tooltip = false;
        };

        "memory" = {
            format = "RAM {}%";
            tooltip = false;
        };

        "network" = {
            format-wifi = "WiFi ({signalStrength}%)";
            format-ethernet = "Ethernet";
            format-disconnected = "Disconnected";
            tooltip-format = "{ifname} via {gwaddr}";
        };

        "pulseaudio" = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-bluetooth-muted = " {icon}";
            format-muted = " {icon}";
            format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = ["" "" ""];
            };
            on-click = "pavucontrol";
        };

        "tray" = {
            icon-size = 21;
            spacing = 10;
        };
    };
  };

    wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
     hyprsplit
     hyprspace
     hyprbars
    ];


  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig = ''

# Autostart
exec-once = waybar
exec-once = hyprctl setcursor Adwatia 24
exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprspace.so"
exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprbars.so"
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Monitor configuration
monitor=,1920x1080,auto,1

# Input configuration
input {
    kb_layout = gb
    kb_variant = 
    kb_model =
    kb_options =
    kb_rules =
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
    resize_on_border = true
}

# Decoration
#decoration {
#    rounding = 10
#    blur {
#        enabled = true
#        size = 3
#        passes = 1
#    }
#    drop_shadow = yes
#    shadow_range = 4
#    shadow_render_power = 3
#    col.shadow = rgba(1a1a1aee)
#}

# Animations
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layout
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Gestures
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 500
    workspace_swipe_invert = true
    workspace_swipe_min_speed_to_force = 30
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = true
    workspace_swipe_forever = true
}

# Binds
binds {
    workspace_back_and_forth = true
    allow_workspace_cycles = true
    pass_mouse_when_bound = false
}

# Keybindings
bind = SUPER, RETURN, exec, kitty
bind = SUPER, Q, killactive, 
bind = SUPER, M, exit, 
bind = SUPER, E, exec, nautilus
bind = SUPER, V, togglefloating, 
bind = SUPER, R, exec, rofi -show drun
bind = SUPER, P, pseudo, 
bind = SUPER, J, togglesplit, 
bind = SUPER, S, togglespecialworkspace, magic
bind = SUPER, F, fullscreen, 0
bind = SUPER, B, exec, flatpak run app.zen_browser.zen
bind = SUPER, T, workspaceopt, allfloat
bind = SUPER, O, overview:toggle

# Move focus with mainMod + arrow keys
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
bind = SUPER SHIFT, 6, movetoworkspace, 6
bind = SUPER SHIFT, 7, movetoworkspace, 7
bind = SUPER SHIFT, 8, movetoworkspace, 8
bind = SUPER SHIFT, 9, movetoworkspace, 9
bind = SUPER SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = SUPER, mouse_down, workspace, e+1
bind = SUPER, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow

# Volume controls
bind =, XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind =, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind =, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness controls
bind =, XF86MonBrightnessUp, exec, brightnessctl set +5%
bind =, XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Screenshot
bind = SUPER SHIFT, S, exec, grim -g "$(slurp)" - | wl-copy
bind =, Print, exec, grim - | wl-copy

# Workspace rules
workspace = 1, persistent:true
workspace = 2, persistent:true
workspace = 3, persistent:true
workspace = 4, persistent:true
workspace = 5, persistent:true
workspace = 6, persistent:true
workspace = 7, persistent:true
workspace = 8, persistent:true
workspace = 9, persistent:true
workspace = 10, persistent:true

# Special workspace for scratchpad
workspace = special:magic, persistent:true
    '';
  };
}

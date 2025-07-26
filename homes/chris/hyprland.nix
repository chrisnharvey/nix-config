{ config, inputs, pkgs, ... }:
{


  home.packages = with pkgs; [
      wofi
      cava
      kitty
      grim
      slurp
      wl-clipboard
      cliphist
      brightnessctl
      pavucontrol
      networkmanagerapplet
      crystal-dock
      hyprlock
      hyprshot
      libnotify
  ];

  services.hyprpaper.enable = true;
  services.hyprpaper.settings = {
    ipc = "on";
    splash = false;
    splash_offset = 2.0;

    preload =
        [ "~/Pictures/wallpaper.jpg" ];

    wallpaper = [
            ",~/Pictures/wallpaper.jpg"
        ];
    };

gtk = {
      enable = true;
      cursorTheme.package = pkgs.bibata-cursors;
      cursorTheme.name = "Bibata-Modern-Classic";
      cursorTheme.size = 24;
      iconTheme.package = pkgs.papirus-icon-theme;
      iconTheme.name = "Papirus";
      gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    };

  services.swaync.enable = true;

  programs.wlogout = {
      enable = true;
      layout = [
	{
	 label = "shutdown";
	 action = "systemctl poweroff";
	 text = "Shutdown";
	 keybind = "s";
	 circular = true;
	}
	{
	 label = "reboot";
	 action = "systemctl reboot";
	 text = "Reboot";
	 keybind = "r";
	 circular = true;
	}
	{
	 label = "suspend";
	 action = "systemctl hibernate";
	 text = "Hibernate";
	 keybind = "h";
	 circular = true;
        }
      ]; 
    };


  programs.waybar = {
      enable = true;
      # Styling Waybar
      style = ''
               * {
                 font-family: "JetBrainsMono Nerd Font";
                 font-size: 12pt;
                 font-weight: bold;
                 transition-property: background-color;
                 transition-duration: 0.5s;
               }
               .warning, .critical, .urgent {
                 animation-name: blink_red;
                 animation-duration: 1s;
                 animation-timing-function: linear;
                 animation-iteration-count: infinite;
                 animation-direction: alternate;
               }
               window#waybar {
                 background-color: transparent;
               }
               window > box {
                 background-color: rgba(0, 0, 0, 0.30);
                 padding-left:8px;
                 border: 2px #dfa7e7;
               }
         tooltip {
                 background-color: rgba(22, 22, 22, 0.70);
               }
         tooltip label {
                 color: #E2E0EC;
               }
         #custom-launcher {
                 font-size: 20px;
                 padding-left: 8px;
                 padding-right: 6px;
                 color: #7ebae4;
               }
         #mode, #clock, #memory, #temperature,#cpu,#mpd, #custom-wall, #temperature, #backlight, #pulseaudio, #network, #battery, #custom-powermenu, #custom-cava-internal {
                 padding-left: 10px;
                 padding-right: 10px;
               }
               /* #mode { */
               /* 	margin-left: 10px; */
               /* 	background-color: rgb(248, 189, 150); */
               /*     color: rgb(26, 24, 38); */
               /* } */
         #memory {
                 color: #f2f4f8;
               }
         #cpu {
                 color: #f2f4f8;
               }
         #clock {
                 color: #78afe3;
               }
         #pulseaudio {
                 color: #f2f4f8;
               }
         #network {
                 color: #f2f4f8;
               }
         #network.disconnected {
                 color: #f2f4f8;
               }
         #custom-powermenu {
                 color: rgb(242, 143, 173);
                 padding-right: 8px;
               }
         #tray {
                 padding-right: 8px;
                 padding-left: 10px;
               }
	#cava.left, #cava.right {
    		color: #78afe3;
	}
	#cava.left {
    		border-radius: 10px;
	}
	#cava.right {
	}
	#workspaces {
	}
	#workspaces button {
    		color: #78afe3;
		font-size: 24px;
	}
	#workspaces button.active {
		color: #78afe3;
	}
	#workspaces button:hover {
  		box-shadow: none;
  		text-shadow: none;
    		background: none;
    		border: none;
	}
	#workspaces button.urgent {
	   	color: #11111b;
	   	background: #fab387;
	   	border-radius: 10px;
	}
	#custom-sep {
		color: #75A6D7;
		font-size: 18px;
	}
      '';
      # Configuring Waybar
      settings = [{
        "layer" = "top";
        "position" = "left";
        modules-left = [
          "custom/launcher"
	 "hyprland/workspaces"
        ];
        modules-center = [
            "wlr/taskbar"
	#  "cava#right"
        ];
        modules-right = [
          "tray"
        #   "memory"
        #   "cpu"
          "pulseaudio"
          "power-profiles-daemon"
          "battery"
        #   "clock"
          "custom/notification"
        ];
        "custom/notification" = {
            tooltip = false;
            format = "{icon}";
            format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t -sw";
            on-click-right = "swaync-client -d -sw";
            escape = true;
        };
        "wlr/taskbar" = {
            "on-click" = "activate";
        };
        "custom/launcher" = {
          "format" = " ";
          "on-click" = "exec wofi --show drun";
          "on-click-right" = "pkill wlogout || wlogout";
          #"on-click-middle" = "exec default_wall";
          "tooltip" = false;
        };
	"cava#left" = {
          "autosens" = 1;
          "bar_delimiter" = 0;
          "bars" = 18;
          "format-icons" = [
            "<span foreground='#cba6f7'>▁</span>"
            "<span foreground='#cba6f7'>▂</span>"
            "<span foreground='#cba6f7'>▃</span>"
            "<span foreground='#cba6f7'>▄</span>"
            "<span foreground='#89b4fa'>▅</span>"
            "<span foreground='#89b4fa'>▆</span>"
            "<span foreground='#89b4fa'>▇</span>"
            "<span foreground='#89b4fa'>█</span>"
          ];
          "framerate" = 60;
          "higher_cutoff_freq" = 10000;
          "input_delay" = 0;
          "lower_cutoff_freq" = 50;
          "method" = "pipewire";
          "monstercat" = false;
          "reverse" = false;
          "source" = "auto";
          "stereo" = true;
          "waves" = false;
        };
	"cava#right" = {
          "autosens" = 1;
          "bar_delimiter" = 0;
          "bars" = 18;
          "format-icons" = [
            "<span foreground='#cba6f7'>▁</span>"
            "<span foreground='#cba6f7'>▂</span>"
            "<span foreground='#cba6f7'>▃</span>"
            "<span foreground='#cba6f7'>▄</span>"
            "<span foreground='#89b4fa'>▅</span>"
            "<span foreground='#89b4fa'>▆</span>"
            "<span foreground='#89b4fa'>▇</span>"
            "<span foreground='#89b4fa'>█</span>"
          ];
          "framerate" = 60;
          "higher_cutoff_freq" = 10000;
          "input_delay" = 0;
          "lower_cutoff_freq" = 50;
          "method" = "pipewire";
          "monstercat" = false;
          "reverse" = false;
          "source" = "auto";
          "stereo" = true;
          "waves" = false;
        };
        "pulseaudio" = {
          "scroll-step" = 1;
          "format" = "{icon}";
        #   "format" = "{icon}{volume}%";
          "format-muted" = "󰖁";
          "format-icons" = {
            "default" = [ "" "" "" ];
          };
          "on-click" = "pavucontrol";
          "tooltip" = true;
        };
        "power-profiles-daemon" = {
            "format" = "{icon}";
            "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
            "tooltip" = true;
            "format-icons" = {
                "default" = "";
                "performance" = "";
                "balanced" = "";
                "power-saver" = "";
            };
        };
        "battery" = {
          "format" = "{icon}";
          "format-icons" = [ "" "" "" "" "" ];
          "tooltip-format" = "{capacity}% - {timeTo}";
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
        };
        "clock" = {
          "interval" = 1;
          "format" = "{:%I:%M %p  %b %d}";
          "tooltip" = true;
          "tooltip-format"= "<tt>{calendar}</tt>";
        };
        "memory" = {
          "interval" = 1;
          "format" = "󰐿 {percentage}%";
          "states" = {
            "warning" = 85;
          };
        };
        "mpd" = {
          "max-length" = 25;
          "format" = "<span foreground='#bb9af7'></span> {title}";
          "format-paused" = " {title}";
          "format-stopped" = "<span foreground='#bb9af7'></span>";
          "format-disconnected" = "";
          "on-click" = "mpc --quiet toggle";
          "on-click-right" = "mpc update; mpc ls | mpc add";
          "on-click-middle" = "kitty --class='ncmpcpp' ncmpcpp ";
          "on-scroll-up" = "mpc --quiet prev";
          "on-scroll-down" = "mpc --quiet next";
          "smooth-scrolling-threshold" = 5;
          "tooltip-format" = "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
        };
        "cpu" = {
          "interval" = 1;
          "format" = "󰍛 {usage}%";
        };
        "network" = {
          "format-disconnected" = "󰯡 Disconnected";
          "format-ethernet" = "󰒢 Connected";
          "format-linked" = "󰖪 {essid} (No IP)";
          "format-wifi" = "󰖩 {essid}";
          "interval" = 1;
          "tooltip" = false;
        };
        "custom/powermenu" = {
          "format" = "";
          "on-click" = "pkill wlogout || wlogout";
        };
        "tray" = {
          "icon-size" = 15;
          "spacing" = 5;
        };
	"hyprland/workspaces" = {
	 "all-outputs" = true;
	 "on-click" = "activate";
	 "format" = "{icon}";
    	 "on-scroll-up" = "hyprctl dispatch workspace e+1";
    	 "on-scroll-down" = "hyprctl dispatch workspace e-1";
	 "format-icons" = {
	   "default" = "";
	   "active" = "";
	   "urgent" = "";
	 };
	};
	"hyprland/window" = {
	 "max-length" = 200;
	 "separate-outputs" = true;
	};
      }];
    };

    wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
    #  hyprexpo
    #  hyprsplit
    #  hyprspace
    #  hyprbarsy
    # hyprscrolling
    hy3
    # hyprexpo
    ];


  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig = ''

# Autostart
exec-once = waybar
exec-once = nm-applet
exec-once = blueman-applet
exec-once = hyprctl setcursor Bibata-Modern-Classic 24
# exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprexpo.so"
# exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprspace.so"
# exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhyprscrolling.so"
exec-once = hyprctl plugin load "$HYPR_PLUGIN_DIR/lib/libhy3.so"
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
        tap-to-click = false
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
    layout = hy3
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
    # bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 10, default, slide
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default, slidevert
}

# Layout
dwindle {
    pseudotile = yes
    preserve_split = yes
}

plugin {
    hyprscrolling {
        fullscreen_on_one_column = true
        column_width = 1
    }

    hy3 {
        tab_first_window = true
    }
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
bind = SUPER, SPACE, exec, wofi --show drun
bind = SUPER, P, pseudo, 
bind = SUPER, J, togglesplit, 
# bind = SUPER, S, togglespecialworkspace, magic
bind = SUPER, W, workspace, e-1
bind = SUPER, S, workspace, e+1
bind = SUPER, A, hy3:movefocus, l
bind = SUPER, D, hy3:movefocus, r
bind = SUPER, F, fullscreen, 0
bind = SUPER, B, exec, flatpak run app.zen_browser.zen
bind = SUPER, C, exec, code
bind = SUPER, T, hy3:changegroup, toggletab
# bind = SUPER, O, overview:toggle

# Move focus with mainMod + arrow keys
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

bind = , PRINT, exec, hyprshot -m output
bind = SHIFT, PRINT, exec, hyprshot -m region

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
# workspace = 1, persistent:true
# workspace = 2, persistent:true
# workspace = 3, persistent:true
# workspace = 4, persistent:true
# workspace = 5, persistent:true
# workspace = 6, persistent:true
# workspace = 7, persistent:true
# workspace = 8, persistent:true
# workspace = 9, persistent:true
# workspace = 10, persistent:true

layerrule = blur,waybar
layerrule = blur,wofi
layerrule = blur,^(swaync-control-center)$

windowrulev2 = opacity 0.99 0.99,class:^(firefox)$
windowrulev2 = float,class:^(qt5ct)$
windowrulev2 = float,class:^(nwg-look)$
windowrulev2 = float,class:^(org.kde.ark)$
windowrulev2 = float,class:^(Signal)$ #Signal-Gtk
windowrulev2 = float,class:^(com.github.rafostar.Clapper)$ #Clapper-Gtk
windowrulev2 = float,class:^(app.drey.Warp)$ #Warp-Gtk
windowrulev2 = float,class:^(net.davidotek.pupgui2)$ #ProtonUp-Qt
windowrulev2 = float,class:^(yad)$ #Protontricks-Gtk
windowrulev2 = float,class:^(eog)$ #Imageviewer-Gtk
windowrulev2 = float,class:^(io.gitlab.theevilskeleton.Upscaler)$ #Upscaler-Gtk
windowrulev2 = float,class:^(pavucontrol)$
windowrulev2 = float,class:^(blueman-manager)$
windowrulev2 = float,class:^(nm-applet)$
windowrulev2 = float,class:^(nm-connection-editor)$
windowrulev2 = float,class:^(org.kde.polkit-kde-authentication-agent-1)$

# Special workspace for scratchpad
workspace = special:magic, persistent:true
    '';
  };
}

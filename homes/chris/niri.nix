{
  config,
  inputs,
  pkgs,
  ...
}:

let
  swaylockCmd = "${pkgs.swaylock-effects}/bin/swaylock -fF --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
in
{

  home.packages = with pkgs; [
    fuzzel
    nixfmt
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
    libnotify
    tailscale-systray
    nautilus
    gnome-keyring
    swaybg
  ];

  home.file.".config/niri/config.kdl".enable = true;
  home.file.".config/niri/config.kdl".source = ./config/niri/config.kdl;

  gtk = {
    enable = true;
    cursorTheme.package = pkgs.bibata-cursors;
    cursorTheme.name = "Bibata-Modern-Classic";
    cursorTheme.size = 24;
    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name = "Papirus";
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  services.swaync.enable = true;

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = swaylockCmd;
        text = "Lock";
        keybind = "l";
        circular = true;
      }
      {
        label = "logout";
        action = "niri msg action quit";
        text = "Logout";
        keybind = "e";
        circular = true;
      }
      {
        label = "suspend";
        action = "systemctl suspend-then-hibernate";
        text = "Sleep";
        keybind = "z";
        circular = true;
      }
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
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
        circular = true;
      }
    ];
  };

  programs.swaylock.enable = true;
  programs.swaylock.package = pkgs.swaylock-effects;
  services.swayidle.enable = true;
  services.swayidle.events = [
    { event = "before-sleep"; command = swaylockCmd; }
  ];
  services.swayidle.timeouts = [
    {
      timeout = 900;
      command = swaylockCmd;
    }
    {
      timeout = 1800;
      command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    }
  ];

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
                     background-color: rgba(0, 0, 0, 0.8);
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
             #mode, #clock, #memory, #temperature,#cpu,#mpd, #custom-wall, #temperature, #backlight, #pulseaudio, #network, #battery, #custom-powermenu, #custom-cava-internal, #custom-notification, #power-profiles-daemon {
                     padding-left: 10px;
                     padding-right: 10px;
                     color: #f2f4f8;
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
    settings = [
      {
        "layer" = "top";
        "height" = 10;
        "position" = "top";
        modules-left = [
          "custom/launcher"
          "niri/workspaces"
        ];
        modules-center = [
          # "wlr/taskbar"
          "cava#right"
        ];
        modules-right = [
          "tray"
          #   "memory"
          #   "cpu"
          "pulseaudio"
          "power-profiles-daemon"
          "battery"
          "custom/notification"
          "clock"
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
          "on-click" = "exec fuzzel";
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
            "default" = [
              ""
              ""
              ""
            ];
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
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
          "tooltip-format" = "{capacity}% - {timeTo}";
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
        };
        "clock" = {
          "interval" = 1;
          # "format" = "{:%H\n%M}";
          "format" = "{:%I:%M %p  %b %d}";
          "tooltip" = true;
          "tooltip-format" = "{:%b %d}";
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
          "spacing" = 20;
        };
        "niri/workspaces" = {
          "all-outputs" = true;
          "on-click" = "activate";
          "format" = "{icon}";
          "format-icons" = {
            "default" = "";
            "active" = "";
            "urgent" = "";
          };
        };
      }
    ];
  };
}

{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  swaylockCmd = "${pkgs.swaylock-effects}/bin/swaylock -fF --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 7 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 --grace 2 --fade-in 0.2";
in
{
  imports = [
    ./desktop.nix
    ./backup.nix
    inputs.walker.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    nixfmt
    cava
    kitty
    grim
    slurp
    wl-clipboard
    cliphist
    brightnessctl
    pavucontrol
    playerctl
    networkmanagerapplet
    crystal-dock
    libnotify
    nemo-with-extensions
    nemo-preview
    nemo-fileroller
    nemo-python
    nemo-emblems
    gnome-keyring
    swaybg
    poweralertd
    wlr-randr
    inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.writeScriptBin "list-downloads" (builtins.readFile ./scripts/list-downloads.sh))
    (pkgs.writeScriptBin "lid-switch" (builtins.readFile ./scripts/lid-switch.sh))
    (pkgs.writeScriptBin "waybar-monitor" (builtins.readFile ./scripts/waybar-monitor.sh))

    # https://github.com/mattn/tailscale-systray/pull/38
    (tailscale-systray.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "chrisnharvey";
        repo = "tailscale-systray";
        rev = "no-pkexec";
        sha256 = "sha256-jsrKrVJgffdc/IvtMsVdkgf+YiiSRs6BCd5uCWtOU2c=";
      };
    }))
  ];

  home.file.".config/niri/config.kdl".enable = true;
  home.file.".config/niri/config.kdl".source = ./config/niri/config.kdl;

  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    window = {
      decorations = "None";
    };
  };

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
  services.swayosd.enable = true;

  systemd.user.services =
    let
      emptyConditionEnvironment = {
        Unit = {
          # remove condition on WAYLAND_DISPLAY, as it supports running on Linux Mint with an Xorg-Session
          ConditionEnvironment = lib.mkForce "";
        };
      };
    in
    {
      walker = emptyConditionEnvironment;
      elephant = emptyConditionEnvironment;
    };

  # Walker
  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      click_to_close = true;
      force_keyboard_focus = true;

      # Configure providers and their prefixes
      providers = {
        prefixes = [
          {
            provider = "calc";
            prefix = "=";
          }
          {
            provider = "files";
            prefix = "/";
          }
          {
            provider = "clipboard";
            prefix = ":";
          }
          {
            provider = "symbols";
            prefix = ".";
          }
          {
            provider = "providerlist";
            prefix = ";";
          }
        ];
      };

      # Keybinds
      keybinds = {
        close = "Escape";
        next = "Down";
        previous = "Up";
      };
    };
  };

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
    {
      event = "before-sleep";
      command = swaylockCmd;
    }
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

  services.gnome-keyring.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita";
    };

    "org/gnome/desktop/wm/preferences" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita";
      button-layout = "appmenu:";
    };

    "org/cinnamon/desktop/applications/terminal" = {
      exec = "alacritty";
    };
  };

  programs.waybar.enable = true;
  home.file.".config/waybar/style.css".enable = true;
  home.file.".config/waybar/style.css".source = ./config/waybar/style.css;
  home.file.".config/waybar/config".enable = true;
  home.file.".config/waybar/config".source = ./config/waybar/config.json;
}

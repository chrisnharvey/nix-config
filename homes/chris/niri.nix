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
  imports = [
    ./desktop.nix
    ./backup.nix
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
    nautilus
    gnome-keyring
    swaybg
    (pkgs.writeScriptBin "list-downloads" (builtins.readFile ./scripts/list-downloads.sh))

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

  programs.fuzzel = {
    enable = true;
    settings = {
      colors = {
        background = "000000cc"; # semi-transparent black
        text = "f2f4f8ff"; # your main white
        match = "dfa7e7ff"; # magenta (for filter match highlight)
        selection = "322647cc"; # deep purple bg for selection
        selection-text = "78afe3ff"; # blue for text in selection
        border = "dfa7e7ff"; # magenta border (if supported by compositor)
        prompt = "7ebae4ff"; # blue prompt glyph (looks nice)
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
      gtk-theme = "Adwaita-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      button-layout = "appmenu:";
    };
  };

  programs.waybar.enable = true;
  home.file.".config/waybar/style.css".enable = true;
  home.file.".config/waybar/style.css".source = ./config/waybar/style.css;
  home.file.".config/waybar/config".enable = true;
  home.file.".config/waybar/config".source = ./config/waybar/config.json;
}

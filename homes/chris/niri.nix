{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./desktop.nix
    ./backup.nix
    inputs.walker.homeManagerModules.default
    inputs.dankMaterialShell.homeModules.dankMaterialShell.default
  ];

  programs.dankMaterialShell.enable = true;
  home.file.".config/DankMaterialShell/settings.json".enable = true;
  home.file.".config/DankMaterialShell/settings.json".source = ./config/dms/settings.json;

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
    libnotify
    nemo-with-extensions
    nemo-preview
    nemo-fileroller
    nemo-python
    nemo-emblems
    gnome-keyring
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
}

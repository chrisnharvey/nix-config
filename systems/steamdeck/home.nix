{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../homes/chris/common.nix
    ../../homes/chris/desktop.nix
  ];

  home.packages = with pkgs; [
    nemo-with-extensions
    nemo-preview
    nemo-fileroller
    nemo-python
    nemo-emblems
  ];

  dconf.settings = {
    # Workspace behavior
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;
    };

    # Shell & Extensions
    "org/gnome/shell" = {
      enabled-extensions = [
        "gjsosk@vishram1123.com"
        "ddterm@amezin.github.com"
        "tailscale@joaophi.github.com"
        "wiggle@mechtifs"
        "caffeine@patapon.info"
        "PrivacyMenu@stuarthayhurst"
        "clipboard-indicator@tudmotu.com"
        "quick-settings-audio-panel@rayzeq.github.io"
        "pip-on-top@rafostar.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "mediacontrols@cliffniff.github.com"
      ];
    };

    "org/gnome/shell/extensions/gjsosk" = {
      enable-tap-gesture = 2;
      layout-portrait = 4;
      layout-landscape = 4;
      landscape-width-percent = 100;
      landscape-height-percent = 50;
      font-size-px = 18;
      font-bold = false;
      round-key-corners = true;
      show-icons = false;
      background-a = 1.0;
      background-a-dark = 1.0;
      background-b = 250.0;
      background-b-dark = 50.0;
      background-g = 250.0;
      background-g-dark = 50.0;
      background-r = 250.0;
      background-r-dark = 50.0;
      border-spacing-px = 2;
      default-snap = 7;
      enable-drag = true;
      indicator-enabled = true;
      outer-spacing-px = 20;
      play-sound = true;
      portrait-height-percent = 30;
      portrait-width-percent = 100;
      snap-spacing-px = 25;
      default-monitor = "1:eDP-1";
      system-accent-col = false;
    };

    # PiP on Top Extension
    "org/gnome/shell/extensions/pip-on-top" = {
      stick = true;
    };

    # Quick Settings Audio Panel Extension
    "org/gnome/shell/extensions/quick-settings-audio-panel" = {
      always-show-input-volume-slider = false;
      autohide-profile-switcher = false;
      create-mpris-controllers = false;
      create-profile-switcher = false;
      merged-panel-position = "top";
      panel-type = "merged-panel";
      version = 2;
      widgets-order = [
        "mpris-controllers"
        "profile-switcher"
        "output-volume-slider"
        "perdevice-volume-sliders"
        "balance-slider"
        "input-volume-slider"
        "applications-volume-sliders"
      ];
    };

    # Privacy Menu Extension
    "org/gnome/shell/extensions/privacy-menu" = {
      click-to-toggle = false;
      group-quick-settings = true;
      use-quick-settings = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      sigma = 20;
      brightness = 0.60;
      style-panel = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      sigma = 20;
      brightness = 0.60;
      style-dialogs = 3;
    };

    "org/gnome/shell/extensions/mediacontrols" = {
      scroll-labels = false;
      extension-position = "Left";
      extension-index = lib.hm.gvariant.mkUint32 1;
      show-control-icons = false;
    };

    "org/gnome/shell/extensions/gtk4-ding" = {
      free-position-icons = true;
      show-home = false;
      show-trash = false;
      show-volumes = false;
    };
  };
}

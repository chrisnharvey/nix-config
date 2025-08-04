{ config, pkgs, lib, ... }: {
  imports =
  [
    ./desktop.nix
  ];

  dconf.settings = {

    # General GNOME Interface Settings
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };

    # Workspace behavior
    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;
    };

    # Touchpad settings
    "org/gnome/desktop/peripherals/touchpad" = {
      disable-while-typing = false;
      tap-to-click = false;
      natural-scroll = true;
      two-finger-scrolling-enabled = true;
      click-method = "fingers";
      speed = 0.193798449612403;
    };

    # Shell & Extensions
    "org/gnome/shell" = {
      enabled-extensions = [
        "ddterm@amezin.github.com"
        "hibernate-status@dromi"
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
        "gtk4-ding@smedius.gitlab.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    # PiP on Top Extension
    "org/gnome/shell/extensions/pip-on-top" = { stick = true; };

    # Hibernate Status Button Extension
    "org/gnome/shell/extensions/hibernate-status-button" = {
      show-suspend = false;
      show-hibernate = true;
      show-hybrid-sleep = true;
      show-suspend-then-hibernate = false;
      show-restart = true;
      show-custom-reboot = true;
      show-shutdown = true;
      show-hibernate-dialog = true;
      show-hybrid-sleep-dialog = false;
      show-suspend-then-hibernate-dialog = false;
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

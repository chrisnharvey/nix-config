{ config, pkgs, ... }:
{
  imports = [
    ../../homes/chris/common.nix
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

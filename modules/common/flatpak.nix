{ config, lib, pkgs, ... }:
{
  # Flatpak support
  services.flatpak.enable = lib.mkDefault true;

  services.flatpak.remotes = lib.mkDefault [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  services.flatpak.update.auto.enable = lib.mkDefault true;
  services.flatpak.uninstallUnmanaged = lib.mkDefault true;

  # Common flatpak applications
  services.flatpak.packages = lib.mkDefault [
    "app.zen_browser.zen"
    "com.getpostman.Postman"
    "md.obsidian.Obsidian"
    "org.gnome.Boxes"
    "org.gnome.Calendar"
    "org.gnome.Contacts"
    "org.gnome.Geary"
    "io.github.mrvladus.List"
    "org.gnome.SimpleScan"
    "org.gnome.gedit"
    "org.signal.Signal"
    "org.videolan.VLC"
    "org.gnome.Papers"
    "org.gnome.Loupe"
    "org.virt_manager.virt-manager"
  ];

  # Global flatpak overrides
  services.flatpak.overrides = {
    global = {
      # Force Wayland by default
      Context.sockets = [
        "wayland"
        "!x11"
        "!fallback-x11"
      ];

      Environment = {
        # Force correct theme for some GTK apps
        GTK_THEME = "Adwaita:dark";
      };
    };
  };
}

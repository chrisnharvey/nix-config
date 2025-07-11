{ config, pkgs, lib, ... }: {
  home.packages = with pkgs; [
    vscode
    jetbrains.goland
    jetbrains.phpstorm
    jetbrains.datagrip
    code-cursor
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
    # Web
    "text/html" = "app.zen_browser.zen.desktop";
    "x-scheme-handler/http" = "app.zen_browser.zen.desktop";
    "x-scheme-handler/https" = "app.zen_browser.zen.desktop";
    "x-scheme-handler/about" = "app.zen_browser.zen.desktop";
    "x-scheme-handler/unknown" = "app.zen_browser.zen.desktop";

    # VLC for Video
    "video/mp4"              = "org.videolan.VLC.desktop";
    "video/x-matroska"       = "org.videolan.VLC.desktop";  # .mkv
    "video/x-msvideo"        = "org.videolan.VLC.desktop";  # .avi
    "video/webm"             = "org.videolan.VLC.desktop";
    "video/quicktime"        = "org.videolan.VLC.desktop";  # .mov
    "video/mpeg"             = "org.videolan.VLC.desktop";
    "video/ogg"              = "org.videolan.VLC.desktop";
    "video/x-flv"            = "org.videolan.VLC.desktop";
    "video/3gpp"             = "org.videolan.VLC.desktop";
    "video/3gpp2"            = "org.videolan.VLC.desktop";

    # VLC for Audio
    "audio/mpeg"             = "org.videolan.VLC.desktop";  # .mp3
    "audio/x-wav"            = "org.videolan.VLC.desktop";  # .wav
    "audio/ogg"              = "org.videolan.VLC.desktop";
    "audio/flac"             = "org.videolan.VLC.desktop";
    "audio/mp4"              = "org.videolan.VLC.desktop";
    "audio/webm"             = "org.videolan.VLC.desktop";
    "audio/aac"              = "org.videolan.VLC.desktop";
    "audio/x-ms-wma"         = "org.videolan.VLC.desktop";
    "audio/x-matroska"       = "org.videolan.VLC.desktop";

    # Playlists / Streams
    "application/x-mpegURL"  = "org.videolan.VLC.desktop";  # .m3u8
    "audio/x-mpegurl"        = "org.videolan.VLC.desktop";  # .m3u

    # Email (Geary)
    "x-scheme-handler/mailto" = "org.gnome.Geary.desktop";

    # GNOME Image Viewer (eog) for image files
    "image/jpeg"               = "org.gnome.eog.desktop";  # .jpg, .jpeg
    "image/png"                = "org.gnome.eog.desktop";
    "image/gif"                = "org.gnome.eog.desktop";
    "image/bmp"                = "org.gnome.eog.desktop";
    "image/tiff"               = "org.gnome.eog.desktop";  # .tif
    "image/webp"               = "org.gnome.eog.desktop";
    "image/x-icon"             = "org.gnome.eog.desktop";  # .ico
    "image/svg+xml"            = "org.gnome.eog.desktop";  # SVG vector image
    "image/x-xbitmap"          = "org.gnome.eog.desktop";  # .xbm
    "image/x-portable-bitmap"  = "org.gnome.eog.desktop";  # .pbm
    "image/x-portable-graymap" = "org.gnome.eog.desktop";  # .pgm
    "image/x-portable-pixmap"  = "org.gnome.eog.desktop";  # .ppm
    "image/x-xpixmap"          = "org.gnome.eog.desktop";  # .xpm

    # GNOME Papers for Documents and Comic Books
    "application/pdf"           = "org.gnome.Papers.desktop";  # PDF
    "image/vnd.djvu"            = "org.gnome.Papers.desktop";  # DjVu
    "application/x-cbr"         = "org.gnome.Papers.desktop";  # CBR
    "application/x-cbz"         = "org.gnome.Papers.desktop";  # CBZ
    "application/x-cbt"         = "org.gnome.Papers.desktop";  # CBT
    "application/x-cb7"         = "org.gnome.Papers.desktop";  # CB7

    # Calendars (GNOME Calendar)
    "text/calendar" = "org.gnome.Calendar.desktop";              # .ics files
    "application/x-ical" = "org.gnome.Calendar.desktop";         # alternate calendar MIME
    "x-scheme-handler/webcal" = "org.gnome.Calendar.desktop";    # webcal:// links
    };
  };

  dconf.settings = {

    # General GNOME Interface Settings
    "org/gnome/desktop/interface" = { enable-hot-corners = false; };

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

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      sigma = 10;
      brightness = 1.0;
      style-dash-to-dock = 2;
      override-background = true;
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
    };
  };
}

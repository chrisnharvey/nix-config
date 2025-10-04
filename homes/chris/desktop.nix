{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    vscode
    jetbrains.goland
    jetbrains.phpstorm
    jetbrains.datagrip
    jetbrains.idea-community-bin
    # code-cursor
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # File Manager
      "inode/directory" = [ "nemo.desktop" ];
      "application/x-gnome-saved-search" = [ "nemo.desktop" ];

      # Web
      "text/html" = "app.zen_browser.zen.desktop";
      "x-scheme-handler/http" = "app.zen_browser.zen.desktop";
      "x-scheme-handler/https" = "app.zen_browser.zen.desktop";
      "x-scheme-handler/about" = "app.zen_browser.zen.desktop";
      "x-scheme-handler/unknown" = "app.zen_browser.zen.desktop";

      # VLC for Video
      "video/mp4" = "org.videolan.VLC.desktop";
      "video/x-matroska" = "org.videolan.VLC.desktop"; # .mkv
      "video/x-msvideo" = "org.videolan.VLC.desktop"; # .avi
      "video/webm" = "org.videolan.VLC.desktop";
      "video/quicktime" = "org.videolan.VLC.desktop"; # .mov
      "video/mpeg" = "org.videolan.VLC.desktop";
      "video/ogg" = "org.videolan.VLC.desktop";
      "video/x-flv" = "org.videolan.VLC.desktop";
      "video/3gpp" = "org.videolan.VLC.desktop";
      "video/3gpp2" = "org.videolan.VLC.desktop";

      # VLC for Audio
      "audio/mpeg" = "org.videolan.VLC.desktop"; # .mp3
      "audio/x-wav" = "org.videolan.VLC.desktop"; # .wav
      "audio/ogg" = "org.videolan.VLC.desktop";
      "audio/flac" = "org.videolan.VLC.desktop";
      "audio/mp4" = "org.videolan.VLC.desktop";
      "audio/webm" = "org.videolan.VLC.desktop";
      "audio/aac" = "org.videolan.VLC.desktop";
      "audio/x-ms-wma" = "org.videolan.VLC.desktop";
      "audio/x-matroska" = "org.videolan.VLC.desktop";

      # Playlists / Streams
      "application/x-mpegURL" = "org.videolan.VLC.desktop"; # .m3u8
      "audio/x-mpegurl" = "org.videolan.VLC.desktop"; # .m3u

      # Email (Geary)
      "x-scheme-handler/mailto" = "org.gnome.Geary.desktop";

      # GNOME Image Viewer (eog) for image files
      "image/jpeg" = "org.gnome.Loupe.desktop"; # .jpg, .jpeg
      "image/png" = "org.gnome.Loupe.desktop";
      "image/gif" = "org.gnome.Loupe.desktop";
      "image/bmp" = "org.gnome.Loupe.desktop";
      "image/tiff" = "org.gnome.Loupe.desktop"; # .tif
      "image/webp" = "org.gnome.Loupe.desktop";
      "image/x-icon" = "org.gnome.Loupe.desktop"; # .ico
      "image/svg+xml" = "org.gnome.Loupe.desktop"; # SVG vector image
      "image/x-xbitmap" = "org.gnome.Loupe.desktop"; # .xbm
      "image/x-portable-bitmap" = "org.gnome.Loupe.desktop"; # .pbm
      "image/x-portable-graymap" = "org.gnome.Loupe.desktop"; # .pgm
      "image/x-portable-pixmap" = "org.gnome.Loupe.desktop"; # .ppm
      "image/x-xpixmap" = "org.gnome.Loupe.desktop"; # .xpm

      # GNOME Papers for Documents and Comic Books
      "application/pdf" = "org.gnome.Papers.desktop"; # PDF
      "image/vnd.djvu" = "org.gnome.Papers.desktop"; # DjVu
      "application/x-cbr" = "org.gnome.Papers.desktop"; # CBR
      "application/x-cbz" = "org.gnome.Papers.desktop"; # CBZ
      "application/x-cbt" = "org.gnome.Papers.desktop"; # CBT
      "application/x-cb7" = "org.gnome.Papers.desktop"; # CB7

      # Calendars (GNOME Calendar)
      "text/calendar" = "org.gnome.Calendar.desktop"; # .ics files
      "application/x-ical" = "org.gnome.Calendar.desktop"; # alternate calendar MIME
      "x-scheme-handler/webcal" = "org.gnome.Calendar.desktop"; # webcal:// links
    };
  };
}

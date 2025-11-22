{ config, lib, ... }:
{
  # Common locale and timezone settings for UK-based systems
  time.timeZone = lib.mkDefault "Europe/London";

  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";

  i18n.extraLocaleSettings = lib.mkDefault {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Console keymap
  console.keyMap = lib.mkDefault "uk";
}

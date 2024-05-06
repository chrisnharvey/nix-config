{ config, pkgs, ... }:
{
  imports =
    [
      ../common/home.nix
    ];

    programs.zsh.autosuggestion.enable = true;

    programs.plasma = {
      enable = true;

      workspace = {
        clickItemTo = "select";
      };

      configFile = {
        "baloofilerc"."General"."only basic indexing".value = true;
        "kcminputrc"."Libinput.1739.52631.DELL08E0:00 06CB:CD97 Touchpad"."DisableWhileTyping".value = false;
        "kcminputrc"."Libinput.1739.52631.DELL08E0:00 06CB:CD97 Touchpad"."NaturalScroll".value = true;
        "ksplashrc"."KSplash"."Engine".value = "none";
        "kwinrc"."TabBox"."LayoutName".value = "thumbnail_grid";
        "ksmserverrc"."General"."loginMode".value = "restoreSavedSession";

        /* disable hotcorners */
        "kwinrc"."Effect-overview"."BorderActivate".value = 9;
        "kwinrc"."Effect-windowview"."BorderActivateAll".value = 9;
      };
    };
}

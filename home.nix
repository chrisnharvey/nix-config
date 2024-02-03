{ config, pkgs, ... }:
{


    programs.plasma = {
      enable = true;

      workspace = {
        clickItemTo = "select";
      };

      configFile = {
        "baloofilerc"."General"."only basic indexing" = true;
        "kcminputrc"."Libinput.1739.52631.DELL08E0:00 06CB:CD97 Touchpad"."DisableWhileTyping" = false;
        "kcminputrc"."Libinput.1739.52631.DELL08E0:00 06CB:CD97 Touchpad"."NaturalScroll" = true;
        "ksplashrc"."KSplash"."Engine" = "none";
        "kwinrc"."TabBox"."LayoutName" = "thumbnail_grid";
        "ksmserverrc"."General"."loginMode" = "restoreSavedSession";

        /* disable hotcorners */
        "kwinrc"."Effect-windowview"."BorderActivateAll" = 9;
      };
    };

    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "23.11";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */

    #programs.plasma.workspace.clickItemTo = "select";

    programs.starship.enable = true;

    programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        oh-my-zsh = {
          enable = true;
          plugins = ["git" "command-not-found" "docker" "docker-compose" "emoji" "git-auto-fetch" "gh" "genpass" "golang" "starship"];
          theme = "robbyrussell";
        };
    };

    programs.git = {
      enable = true;
      userName = "Chris Harvey";
      userEmail = "chris@chrisnharvey.com";
    };
}

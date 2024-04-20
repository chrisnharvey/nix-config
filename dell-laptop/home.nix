{ config, pkgs, ... }:
{


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
        "kwinrc"."Effect-windowview"."BorderActivateAll".value = 9;
      };
    };

    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "23.11";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */

    #programs.plasma.workspace.clickItemTo = "select";

    programs.starship.enable = true;

    programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
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
      signing.key = "0B5B154A0538BD357EE58189024E65A3F7E92A36";
      signing.signByDefault = true;
    };
}

{ config, pkgs, ... }:
{
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "23.11";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */

    programs.starship.enable = true;

    programs.zsh = {
        enable = true;
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
      extraConfig = {
        url."git@github.com:".insteadOf = "https://github.com/";
      };
    };
}

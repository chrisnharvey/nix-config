{ config, pkgs, ... }:
{
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "24.05";
    /* Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ]; */

    home.packages = with pkgs; [
      zoxide
      keybase
      kbfs
      kubectl
      kubernetes-helm
      hugo
      go
      gcc         
      php
      phpPackages.composer
      nodejs
    ];

    home.sessionVariables = {
      EDITOR = "nano"; # Don't judge me!
      GOPATH = "$HOME/go";
      GOPRIVATE = "github.com/*";
    };

    programs.starship.enable = true;

    programs.nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = ["git" "command-not-found" "docker" "docker-compose" "emoji" "git-auto-fetch" "gh" "genpass" "golang" "starship" "zoxide"];
          theme = "robbyrussell";
        };
        shellAliases = {
          nix-shell = "nix-shell --run $SHELL";
          docker-nuke = "docker rm -f \$(docker ps -aq)";
          docker-image-nuke = "docker rmi -f \$(docker images -aq)";
          docker-volume-nuke = "docker volume rm \$(docker volume ls -q)";
          docker-network-nuke = "docker network rm \$(docker network ls -q)";
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

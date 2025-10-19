{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.borgmatic.enable = true;
  services.borgmatic.frequency = "daily";
  systemd.user.services.borgmatic.Unit.ConditionACPower = lib.mkForce false;
  programs.borgmatic = {
    enable = true;
    backups = {
      home = {
        location = {
          repositories = [ "ssh://chris@192.168.10.9/data/data/files/Backups/dell-laptop" ];
          patterns = [
            "R /home/chris"
            "+ ."
            "- Downloads"
            "- .cache"
            "- .local/share/Trash"
            "- .steam"
            "- .var/app"
            "- **/node_modules"
          ];
        };
        retention = {
          keepDaily = 7;
        };

        hooks = {
          extraConfig = {
            commands = [
              {
                before = "action";
                when = [ "create" ];
                run = [
                  "notify-send 'Backup Started' 'Borgmatic backup started' --urgency=low --transient --app-name='Borgmatic'"
                ];
              }
              {
                after = "action";
                when = [ "create" ];
                states = [ "finish" ];
                run = [
                  "notify-send 'Backup Finished' 'Borgmatic backup finished' --urgency=low --transient --app-name='Borgmatic'"
                ];
              }
              {
                after = "action";
                when = [ "create" ];
                states = [ "fail" ];
                run = [
                  "notify-send -u critical 'Backup Failed' 'Borgmatic backup failed' --urgency=critical --app-name='Borgmatic'"
                ];
              }
              {
                after = "action";
                when = [ "prune" ];
                states = [ "finish" ];
                run = [
                  "notify-send 'Backup Prune Finished' 'Borgmatic backup prune finished' --urgency=low --transient --app-name='Borgmatic'"
                ];
              }
              {
                after = "action";
                when = [ "prune" ];
                states = [ "fail" ];
                run = [
                  "notify-send -u critical 'Backup Prune Failed' 'Borgmatic backup prune failed' --urgency=critical --app-name='Borgmatic'"
                ];
              }
            ];
          };
        };

        consistency = {
          checks = [
            {
              name = "repository";
              frequency = "2 weeks";
            }
            {
              name = "archives";
              frequency = "4 weeks";
            }
          ];
        };
      };
    };
  };
}

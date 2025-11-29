{
  config,
  pkgs,
  environment,
  ...
}:
{
  services.greetd.enable = true;

  programs.dankMaterialShell.greeter = {
    enable = true;
    compositor.name = "niri";
    configFiles = [ ./config/dms/settings.json ];
    compositor.customConfig = (builtins.readFile ./config/niri/niri-greeter.kdl);
  };
}

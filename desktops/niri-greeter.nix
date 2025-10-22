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
    configHome = "/home/chris";
    compositor.customConfig = (builtins.readFile ./config/niri/niri-greeter.kdl);
  };
}

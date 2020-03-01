{ config, pkgs, ... } :
{
  environment.systemPackages =
    let
      xfce = pkgs.xfce;
    in [
    xfce.xfce4-cpufreq-plugin
    xfce.xfce4-netload-plugin
    xfce.xfce4-xkb-plugin
    xfce.xfce4-embed-plugin
    xfce.xfce4-battery-plugin
    # xfce.xfce4-verve-plugin
    xfce.xfce4-clipman-plugin
    xfce.xfce4-datetime-plugin
    xfce.xfce4-netload-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-netload-plugin
    xfce.xfce4-windowck-plugin

    xfce.gigolo
    xfce.xfce4-taskmanager
  ];

  # nixpkgs.config = {
  #   packageOverrides = pkgs : {
  #     xfce4-14 = pkgs.xfce4-14 // rec {
  #       xfce4-xkb-plugin = pkgs.lib.overrideDerivation (pkgs.xfce4-14.xfce4-xkb-plugin) (o:{
  #         name = o.name + "-patched";
  #         patches = [ ../pkgs/xfce4-xkb.patch ];
  #       });
  #     };
  #   };
  # };
}

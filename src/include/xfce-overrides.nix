{ config, pkgs, ... } :
{
  environment.systemPackages =
    let
      xfce414 = pkgs.xfce4-14;
      xfce = pkgs.xfce;
    in [
    xfce414.xfce4-cpufreq-plugin
    xfce414.xfce4-netload-plugin
    xfce414.xfce4-xkb-plugin
    xfce414.xfce4-embed-plugin
    xfce414.xfce4-battery-plugin
    # xfce.xfce4-verve-plugin
    xfce414.xfce4-clipman-plugin
    xfce.xfce4-datetime-plugin
    xfce414.xfce4-netload-plugin
    xfce.xfce4-weather-plugin
    xfce414.xfce4-pulseaudio-plugin
    xfce414.xfce4-netload-plugin
    xfce414.xfce4-windowck-plugin

    xfce414.gigolo
    xfce414.xfce4-taskmanager
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

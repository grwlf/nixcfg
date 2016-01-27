{ config, pkgs, ... } :
{
  environment.systemPackages = with pkgs ; [
    xfce.xfce4_cpufreq_plugin
    xfce.xfce4_systemload_plugin
    xfce.xfce4_xkb_plugin
    xfce.xfce4_embed_plugin
    xfce.xfce4_battery_plugin
    xfce.xfce4_verve_plugin
    # xfce.xfce4_notes_plugin
    # xfce.xfce4_dict_plugin
    xfce.xfce4_clipman_plugin
    xfce.xfce4_datetime_plugin
    xfce.xfce4_netload_plugin

    xfce.gigolo
    xfce.xfce4taskmanager

    photofetcher
    handyscripts
    videoconvert
  ];

  nixpkgs.config = {
    packageOverrides = pkgs : {

      photofetcher = pkgs.callPackage ../pkgs/photofetcher.nix {};

      handyscripts = pkgs.callPackage ../pkgs/handyscripts.nix {};

      videoconvert = pkgs.callPackage ../pkgs/videoconvert.nix {};

      xfce = pkgs.xfce // rec {

        xfce4_xkb_plugin = pkgs.lib.overrideDerivation (pkgs.xfce.xfce4_xkb_plugin) (o:{
          name = o.name + "-patched";
          patches = [ ../pkgs/xfce4-xkb.patch ];
        });

        thunar-build = pkgs.lib.overrideDerivation pkgs.xfce.thunar-build (a:{
          name = a.name + "-patched";
          prePatch = ''
            cp -pv ${pkgs.callPackage ../pkgs/thunar_uca.nix {}} plugins/thunar-uca/uca.xml.in
          '';
        });

        thunar = pkgs.xfce.thunar.override { inherit thunar-build; };
      };
    };
  };
}

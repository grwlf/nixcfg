{ pkgs ? import <nixpkgs> {}, me } :

let
  local = rec {
    callPackage = pkgs.lib.callPackageWith collection;

    collection = (pkgs // rec {
      inherit me;
      nixpkgs=pkgs;
      placeTo = to : x : pkgs.stdenv.mkDerivation {
        name = "moved"; # can't mention x here to allow simple paths
        buildCommand = ''
          . $stdenv/setup
          mkdir -pv `dirname $out/${to}`
          cp -rv ${x} "$out/${to}"
        '';
      };
      mytmux = pkgs.writeShellScriptBin "tmux" ''
        exec ${pkgs.tmux}/bin/tmux -f ${../cfg/tmux.conf} "$@"
      '';
      myvim = callPackage ./myvim.nix {};
      myprofile = placeTo "/etc/myprofile" (callPackage ./myprofile.nix {});
      cvimrc = placeTo "/etc/cvimrc" (callPackage ./cvimrc.nix {});
      photofetcher = callPackage ./photofetcher.nix {};
      thunar_uca = callPackage ./thunar_uca.nix {};
      xscreensaver-run = pkgs.callPackage ./xscreensaver-run.nix {};
      mylock = callPackage ./mylock.nix {};
      urxvt = (pkgs.rxvt_unicode-with-plugins.override {
        plugins = [
          pkgs.urxvt_perl
          pkgs.urxvt_theme_switch
        ];
      });
      urxvtb = callPackage ./urxvtb.nix {};
      thunar-bare = pkgs.lib.overrideDerivation pkgs.xfce.thunar-bare (a:{
        name = a.name + "-patched";
        prePatch = ''
          cp -pv ${local.collection.thunar_uca} plugins/thunar-uca/uca.xml.in
        '';
      });

      thunar = pkgs.xfce.thunar.override { inherit thunar-bare; };
    });
  };

in
  local.collection

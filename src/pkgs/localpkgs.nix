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
      mysshconfig = placeTo "/etc/ssh_config" (callPackage ./mysshconfig.nix {});
      photofetcher = callPackage ./photofetcher.nix {};
      thunar_uca = callPackage ./thunar_uca.nix {};
      xscreensaver-run = pkgs.callPackage ./xscreensaver-run.nix {};
      mylock = callPackage ./mylock.nix {};
      lssh = callPackage ./lssh.nix {};
      urxvt = (pkgs.rxvt-unicode.override {
        rxvt-unicode-plugins = with pkgs.rxvt-unicode-plugins; {
          inherit perl theme-switch;
        };
      });
      urxvtb = callPackage ./urxvtb.nix {};
      thunar = pkgs.lib.overrideDerivation pkgs.xfce4-14.thunar (a:{
        pname = a.name + "-patched";
        prePatch = ''
          cp -pv ${local.collection.thunar_uca} plugins/thunar-uca/uca.xml.in
        '';
      });
      newsboat = pkgs.writeShellScriptBin "newsboat" ''
        ${pkgs.newsboat}/bin/newsboat \
          -u $HOME/pers/newsboat/urls \
          -C $NIXCFG_ROOT/src/cfg/newsboat \
          "$@"
        '';
      mypython = callPackage ./mypython.nix {};
      deadbeef-opener = callPackage ./deadbeef-opener.nix {};
      deadbeef-lyricbar = callPackage ./deadbeef-lyricbar.nix {};
      mydeadbeef = pkgs.deadbeef-with-plugins.override {
        plugins = [ deadbeef-lyricbar ];
      };
    });
  };

in
  local.collection

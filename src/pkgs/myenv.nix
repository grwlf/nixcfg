{ pkgs ? import <nixpkgs> {} } :

let
  placeTo = to : x : pkgs.stdenv.mkDerivation {
    name = "moved-${x.name}";
    buildCommand = ''
      . $stdenv/setup
      mkdir -pv `dirname $out/${to}`
      cp -rv ${x} "$out/${to}"
    '';
  };

  local = rec {
    callPackage = pkgs.lib.callPackageWith collection;

    collection = (pkgs // rec {
      myvim = callPackage ./myvim.nix {};
      myprofile = callPackage ./myprofile.nix {};
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
    });
  };

  thunar-bare = pkgs.lib.overrideDerivation pkgs.xfce.thunar-bare (a:{
    name = a.name + "-patched";
    prePatch = ''
      cp -pv ${local.collection.thunar_uca} plugins/thunar-uca/uca.xml.in
    '';
  });

  thunar = pkgs.xfce.thunar.override { inherit thunar-bare; };

in
pkgs.buildEnv {
  name = "myenv";
  paths = with local.collection; [
    # Nix-generated configs and binaries
    myvim
    (placeTo "/etc/myprofile" myprofile)

    # Custom XFCE packages
    thunar
    photofetcher
    (pkgs.callPackage ./videoconvert.nix {})

    unclutter
    xorg.xdpyinfo
    xorg.xinput
    urxvt

    # myvim
    xcompmgr
    zathura
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    wine
    libreoffice
    # pidgin
    #skypeforlinux tarball gone
    qbittorrent
    cups
    mlton
    i7z
    pdftk
    tuxguitar
    unetbootin
    zbar

    vlc
    (sox.override { enableLame = true; })
    smplayer
    mplayer

    imagemagickBig
    geeqie
    gimp
    chromium
    encfs
    plowshare
    lsof
    google-drive-ocamlfuse
    ffmpeg

    tdesktop
    jmtpfs
    evince
    cabal2nix
    youtube-dl
    xscreensaver-run
    rss-glx
    xlibs.xeyes

    nvtop
    newsboat

    gkrellm
    lm_sensors
    xsensors
    calibre
    # coq
    mylock
    urxvtb

    easytag
  ];
}


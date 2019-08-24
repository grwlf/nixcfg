{ localpkgs ? import <localpkgs> {}
} :
let
  inherit (localpkgs) pkgs placeTo;
in
pkgs.buildEnv {
  name = "myenv";
  paths = with localpkgs; [
    # Nix-generated configs and binaries
    myvim
    myprofile

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


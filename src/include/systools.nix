{ config, pkgs, ... } :
{

  environment.systemPackages = with pkgs ; [
    psmisc
    wmctrl
    iptables
    tcpdump
    pmutils
    file
    cpufrequtils
    zip
    unzip
    unrar
    p7zip
    openssl
    cacert
    w3m
    wget
    screen
    fuse
    mpg321
    catdoc
    tftp_hpa
    atool
    ppp
    pptp
    dos2unix
    fuse_exfat
    acpid
    upower
    smartmontools
    manpages
    hdparm
    tree
    curlFull
    usbutils
    pciutils
    stunnel
    swaks
    which
    socat
    lsof
    minicom
    bc
    telnet

    # Fun
    cowsay
    toilet
    figlet
    jp2a
    fortune
    figlet
    ddate
    espeak

    mc
    htop
    gitAndTools.gitFull
    git-lfs
    ctags
    subversion
    tig
    mercurial
    plowshare
    pv
    xorg.xhost
    xorg.xkbcomp
    xsel
    pdftk
    jq
  ];
}

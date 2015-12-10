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
    figlet
    manpages
    hdparm
    tree
    curlFull
    usbutils
    stunnel
    usbutils
    swaks
    which
    socat
    lsof
    minicom

    mc
    htop
    gitAndTools.gitFull
    ctags
    subversion
    tig
    mercurial
  ];

}

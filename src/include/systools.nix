{ config, pkgs, ... } :
{
  programs = {
    tmux = {
      enable = true;
    };
  };

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
    hdparm
    manpages
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
    pdftk
    mkpasswd
    sshfs-fuse
    fzf

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
    jq
  ];
}

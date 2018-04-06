# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:

let

  me = "smironov";
  proxyport = "4343";
  backproxyport = "4344";
  localssh=22;

in
rec {
  require = [
      /etc/nixos/hardware-configuration.nix
      ./include/devenv.nix
      ./include/subpixel.nix
      ./include/haskell.nix
      ./include/bashrc.nix
      ./include/cvimrc.nix
      ./include/systools.nix
      ./include/fonts.nix
      ./include/user-smironov.nix
      ./include/postfix_relay.nix
      ./include/templatecfg.nix
      ./include/xfce-overrides.nix
      ./include/wheel.nix
      ./include/ntpd.nix
      ./include/overrides.nix
    ];

  boot.blacklistedKernelModules = [
    "fbcon"
    "pcspkr"
    "snd_pcsp"
    ];

  boot.kernelParams = [
    # Use better scheduler for SSD drive
    #"elevator=noop"
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  boot.kernelModules = [
    "fuse"
  ];

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  };

  time.timeZone = "Europe/Moscow";

  networking = {
    hostName = "ww2";
    networkmanager.enable = true;
    proxy.default = "Mironov_S:${import <passwords/kasper>}@proxy.avp.ru:3128";
  };

  networking.firewall = {
    enable = false;
  };

  services.openssh = {
    enable = true;
    ports = [localssh 2222];
    permitRootLogin = "yes";
    gatewayPorts = "yes";
    forwardX11 = true;
  };

  services.postgresql = {
    enable = true;
    # package = pkgs.postgresql92;

    initialScript = pkgs.writeText "postgreinit.sql" ''
      create role smironov superuser login createdb createrole replication;
    '';
  };

  services.printing = {
    enable = true;
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "@weekly root nix-collect-garbage -d >/root/cronout"
    ];
  };

  services.xserver = {
    enable = true;

    startOpenSSHAgent = true;

    videoDrivers = [ "intel" "ati" "vesa" "cirrus" ];

    layout = "us,ru";

    xkbOptions = "grp:alt_space_toggle, ctrl:swapcaps, grp_led:caps";

    desktopManager = {
      xfce.enable = true;
    };

    displayManager = {
      sddm.enable = true;
    };
  };

  services.autossh.sessions = [
    {
      name = "vps";
      user = me;
      extraArguments = "-4 -N -D${proxyport} vps";
    }
    {
      name = "vps-back";
      user = me;
      extraArguments = "-4 -N -R ${backproxyport}:127.0.0.1:${toString localssh} vps";
    }
  ];

  services.locate = {
    enable = true;
  };

  services.syncthing ={
    enable = true;
    # package = pkgs.syncthing012;
    user = me;
    all_proxy = "socks5://127.0.0.1:${proxyport}";
    dataDir = "/var/lib/syncthing-${me}";
  };

  virtualisation.docker = {
    enable = true;
    extraOptions = "--insecure-registry ft-repo.avp.ru:5000";
  };

  hardware = {
    pulseaudio.enable = true;
  };

  security.pki.certificateFiles = [
    ./certs/kasperskylabsenterpriseca.cer
    ./certs/kasperskylabsmoscowca.cer
    ./certs/kasperskylabspolicyca.cer
    ./certs/kasperskylabsrootca.cer
    ./certs/kasperskylabshqca.cer.pem
  ];

  services.udev = {
    extraRules = ''
      # Android Debug Bridge identifiers
      SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="users"

      KERNEL=="tun", GROUP="users", MODE="0660", OPTIONS+="static_node=net/tun"
    '';
  };

  programs.ssh = {
    extraConfig = "KexAlgorithms +diffie-hellman-group1-sha1";
  };

  environment.systemPackages = with pkgs ; [
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    rxvt_unicode
    glxinfo
    feh
    xcompmgr
    zathura
    evince
    xneur
    mplayer
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    wine
    vlc
    libreoffice
    pidgin
    # skypeforlinux
    pavucontrol
    networkmanagerapplet
    cups
    unetbootin
    dmidecode
    xscreensaver
    wireshark
    ruby
    bvi
    i7z
    encfs
    imagemagick
    chromium
    tdesktop
    myvim
    i3lock
    geeqie
    cabal2nix
    gitRepo
    ffmpeg
    sox
    graphviz
    youtube-dl
  ];

  nixpkgs.config = {
    allowBroken = true;
    allowUnfree = true;
  };

}


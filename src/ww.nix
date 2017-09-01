# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:

rec {
  require = [
      /etc/nixos/hardware-configuration.nix
      ./include/devenv.nix
      ./include/subpixel.nix
      ./include/haskell.nix
      ./include/bashrc.nix
      ./include/systools.nix
      ./include/fonts.nix
      ./include/user-grwlf.nix
      ./include/postfix_relay.nix
      ./include/templatecfg.nix
      ./include/workusers.nix
      ./include/xfce-overrides.nix
      ./include/wheel.nix
    ];

  # boot.kernelPackages = pkgs.linuxPackages_3_12 // {
  #   virtualbox = pkgs.linuxPackages_3_12.virtualbox.override {
  #     enableExtensionPack = true;
  #   };
  # };

  boot.blacklistedKernelModules = [
    "fbcon"
    "pcspkr"
    "snd_pcsp"
    "snd_hda_codec_hdmi"
    ];

  boot.kernelParams = [
    # Use better scheduler for SSD drive
    #"elevator=noop"
    ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel enable=0,1
  '';

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
    hostName = "ww";
    networkmanager.enable = true;
  };

  networking.firewall = {
    enable = false;
  };

  fileSystems = [
    { mountPoint = "/";
      device = "/dev/disk/by-label/ROOT";
      options = "defaults,relatime,discard";
    }
    { mountPoint = "/home";
      device = "/dev/disk/by-label/HOME";
      options = "defaults,relatime,discard";
    }
  ];

  services.ntp = {
    enable = true;
    servers = [ "0.pool.ntp.org" "1.pool.ntp.org" "2.pool.ntp.org" ];
  };

  services.openssh = {
    enable = true;
    ports = [22 2222];
    permitRootLogin = "yes";
    gatewayPorts = "yes";
  };

  services.dbus.packages = [ pkgs.gnome.GConf ];

  services.virtualboxHost.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql92;
  };

  services.printing = {
    enable = true;
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "@weekly root nix-collect-garbage -d >/home/grwlf/cronout"
    ];
  };

  services.xserver = {
    enable = true;

    startOpenSSHAgent = true;

    videoDrivers = [ "intel" ];

    layout = "us,ru";

    xkbOptions = "grp:alt_space_toggle, ctrl:swapcaps, grp_led:caps";

    desktopManager = {
      xfce.enable = true;
    };

    displayManager = {
      lightdm = {
        enable = true;
      };
    };
  };

  hardware = {
    pulseaudio.enable = true;
  };

  services.rsyslogd = {
    enable = true;
    defaultConfig = ''
      module(load="imudp")
      input(type="imudp" port="514")
      action(type="omfile" File="/var/log/netmessages")
    '';
  };

  environment.systemPackages = with pkgs ; [
    # X11 apps
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    rxvt_unicode
    vimHugeX
    firefox
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
    skype
    pavucontrol
    networkmanagerapplet
    cups

    haskell_7_8
    (devenv { enableX11 = services.xserver.enable; })

    mercurial
    unetbootin
    manpages
    socat
    dmidecode
    xscreensaver
    wireshark
    tig
    pv
    mlton
    minicom
    lsof
    i7z
    hdparm
    ruby
    pv
    figlet
    bvi
  ];

  nixpkgs.config = {
    virtualbox.enableExtensionPack = true;
    allowBroken = true;
    allowUnfree = true;
  };

}


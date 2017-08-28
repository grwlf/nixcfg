## FIXME: this file is quite old and not supported

{config, pkgs, ...}:

{
  require = [
    /etc/nixos/hardware-configuration.nix
    ./include/bashrc.nix
    ./include/systools.nix
    ./include/subpixel.nix
    ./include/fonts.nix
    ./include/postfix_relay.nix
    ./include/templatecfg.nix
    ./include/user-grwlf.nix
    ./include/xfce-overrides.nix
    ./include/firefox-with-localization.nix
    ./include/wheel.nix
    ./include/ntpd.nix
  ];

  hardware.pulseaudio.enable = true;

  boot.extraKernelParams = [
    # SSD-friendly
    "elevator=noop"
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    configurationLimit = 10;
    device = "/dev/sda";
  };

  time.timeZone = "Europe/Moscow";

  networking = {
    hostName = "goodfellow";
    networkmanager.enable = true;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-label/ROOT";
      fsType = "ext4";
    };
  fileSystems."/home" =
    { device = "/dev/disk/by-label/HOME";
      fsType = "ext4";
    };

  swapDevices = [
    { device = "/dev/disk/by-label/SWAP"; }
  ];

  powerManagement = {
    enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "ru_RU.UTF-8";
  };

  services.nixosManual.showManual = false;

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = true;
  services.openssh.ports = [ 22 2222 ];

  services.xserver = {
    enable = true;
    layout = "ru,us";
    xkbOptions = "eurosign:e, grp:alt_shift_toggle, grp_led:caps";
    exportConfiguration = true;
    startOpenSSHAgent = true;
    synaptics = {
      enable = true;
      twoFingerScroll = false;
      additionalOptions = ''
        Option "LBCornerButton" "2"
        Option "LTCornerButton" "3"
        '';
    };

    desktopManager.xfce.enable = true;

    displayManager = {
      slim = {
        enable = true;
        defaultUser = "galtimir";
        autoLogin = true;
      };
    };

    videoDrivers = [ "intel" "vesa" ];
  };

  users.extraUsers = {
    galtimir = {
      uid = 1001;
      group = "users";
      extraGroups = ["wheel" "networkmanager"];
      home = "/home/galtimir";
      useDefaultShell = true;
    };
  };

  environment.systemPackages = with pkgs ; [
    # X11 apps
    rxvt_unicode
    vimHugeX
    glxinfo
    feh
    xcompmgr
    zathura
    evince
    xneur
    mplayer
    unclutter
    trayer
    xorg.xdpyinfo
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    ghostscript
    djview4
    skype
    tightvnc
    wine
    vlc
    gimp_2_8
    geeqie
    viewnior
    xfce.xfce4_xkb_plugin
    networkmanagerapplet
    imagemagick
    rtorrent
    firefox
  ];

  nixpkgs.config = {
    allowUnfree = true;
    chrome.enableRealPlayer = false;
    firefox.enableAdobeFlash = true;
    chrome.jre = true;
  };
}

# vim: expandtab : tabstop=2 : autoindent :

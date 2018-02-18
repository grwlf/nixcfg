## FIXME: this file is quite old and not supported

{config, pkgs, ...}:
let

  galtimir = "galtimir";
  vpsport = "4345";
  localssh = 2222;

in

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
    ./include/wheel.nix
    ./include/ntpd.nix
    ./include/overrides.nix
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

  boot.kernelModules = [
    "fuse"
  ];

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

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
    passwordAuthentication = true;
    ports = [ localssh ];
    forwardX11 = true;
    gatewayPorts = "yes";
  };

  services.autossh.sessions = [
    {
      name = "vps-back";
      user = "grwlf";
      extraArguments = "-4 -N -R ${vpsport}:127.0.0.1:${toString localssh} vps";
    }
  ];

  services.syncthing ={
    enable = true;
    package = pkgs.syncthing012;
    user = galtimir;
    dataDir = "/var/lib/syncthing-${galtimir}";
  };

  users.extraUsers = {
    galtimir = {
      uid = 1001;
      group = "users";
      extraGroups = ["wheel" "networkmanager"];
      home = "/home/${galtimir}";
      useDefaultShell = true;
    };
  };

  environment.systemPackages = with pkgs ; [
    # X11 apps
    rxvt_unicode
    myvim
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
    skypeforlinux
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
    pavucontrol
  ];

  nixpkgs.config = {
    allowUnfree = true;
    chrome.enableRealPlayer = false;
    firefox.enableAdobeFlash = false;
    chrome.jre = true;
  };
}

# vim: expandtab : tabstop=2 : autoindent :

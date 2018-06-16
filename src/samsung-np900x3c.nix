# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:
let

  me = "grwlf";

in

rec {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  require = [
      ./include/subpixel.nix
      ./include/haskell.nix
      ./include/bashrc.nix
      ./include/cvimrc.nix
      ./include/systools.nix
      ./include/fonts.nix
      ./include/user-grwlf.nix
      ./include/postfix_relay.nix
      ./include/templatecfg.nix
      ./include/xfce-overrides.nix
      ./include/wheel.nix
      ./include/ntpd.nix
      ./include/overrides.nix
      ./include/containers.nix
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "fuse" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOK";  # Was a typo in `mkfs.ext2` command
      fsType = "ext2";
    };

  fileSystems."/" =
    { device = "/dev/disk/by-label/ROOT";
      fsType = "ext4";
      options = ["defaults" "relatime" "discard"];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/HOME";
      fsType = "ext4";
      options = ["defaults" "relatime" "discard"];
    };

  swapDevices = [ ];

  nix.maxJobs = pkgs.lib.mkDefault 4;

  boot.blacklistedKernelModules = [
    "fbcon"
  ];

  boot.kernelParams = [
    # Use better scheduler for SSD drive
    "elevator=noop"
    "intel_pstate=disable"
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  };

  hardware = {
    # opengl.videoDrivers = [ "vesa" ];
    opengl.driSupport32Bit = true;
    enableAllFirmware = true;
    # firmware = [ "/root/firmware" ];
    bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  time.timeZone = "Europe/Moscow";

  networking = {
    hostName = "greyblade";

    networkmanager.enable = true;
  };

  powerManagement = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [22 2222];
    permitRootLogin = "yes";
    extraConfig = ''
      ClientAliveInterval 20
    '';
  };

  # services.dbus.packages = [ pkgs.gnome.GConf ];

  services.postgresql = {
    enable = true;
    # package = pkgs.postgresql92;
    initialScript =  pkgs.writeText "postgreinit.sql" ''
      create role grwlf superuser login createdb createrole replication;
    '';
  };

  services.printing = {
    enable = true;
  };

  services.xserver = {
    enable = true;

    videoDrivers = [ "intel" ];

    layout = "us,ru";

    xkbOptions = "grp:alt_space_toggle, ctrl:swapcaps, grp_led:caps";

    desktopManager = {
      xfce.enable = true;
    };

    displayManager = {
      # sddm.enable = true;
      lightdm.enable = true;
      # gdm.enable = true;
      # slim = {
      #   enable = true;
      # #   defaultUser = "grwlf";
      # };
    };

    multitouch.enable = false;

    synaptics = {
      enable = true;
      accelFactor = "0.05";
      maxSpeed = "10";
      twoFingerScroll = true;
      additionalOptions = ''
        MatchProduct "ETPS"
        Option "FingerLow"                 "3"
        Option "FingerHigh"                "5"
        Option "FingerPress"               "30"
        Option "MaxTapTime"                "100"
        Option "MaxDoubleTapTime"          "150"
        Option "FastTaps"                  "0"
        Option "VertTwoFingerScroll"       "1"
        Option "HorizTwoFingerScroll"      "1"
        Option "TrackstickSpeed"           "0"
        Option "LTCornerButton"            "3"
        Option "LBCornerButton"            "2"
        Option "CoastingFriction"          "20"
      '';
    };

    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  programs.ssh.startAgent = true;

  virtualisation.virtualbox = {
    host.enable = true;
    guest.enable = true;
  };

  virtualisation.docker = {
    enable = false;
  };

  services.journald = {
    extraConfig = ''
      SystemMaxUse=50M
    '';
  };

  services.autossh = {
    sessions = [
      {
        name="vps";
        user=me;
        monitoringPort = 20000;
        extraArguments="-N -D4343 vps";
      }
    ];
  };

  services.locate = {
    enable = true;
  };

  services.syncthing ={
    package = pkgs.syncthing;
    enable = true;
    user = me;
    dataDir = "/var/lib/syncthing-${me}";
  };

  services.thermald = {
    enable = true;
  };

  services.udev = {
    extraRules = ''
      # Android Debug Bridge identifiers
      SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="users"
    '';
  };

  environment.systemPackages = with pkgs ; [
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    rxvt_unicode
    myvim
    myprofile
    glxinfo
    xcompmgr
    zathura
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    wine
    libreoffice
    pidgin
    skypeforlinux
    networkmanagerapplet
    pavucontrol
    qbittorrent
    cups
    mlton
    i7z
    pdftk
    tuxguitar
    unetbootin
    zbar

    vlc
    sox
    smplayer
    mplayer

    imagemagickBig
    geeqie
    gimp_2_8
    chromium
    encfs
    plowshare
    lsof
    google-drive-ocamlfuse
    ffmpeg
    electrum
    go-ethereum

    tdesktop
    jmtpfs
    evince
    cabal2nix
    youtube-dl
  ];

  nixpkgs.config = {
    sox.enableLame = true;
    allowBroken = true;
    allowUnfree = true;
    chrome = {
      jre = true;
      enableAdobeFlash = true;
    };
    firefox = {
      jre = false;
      enableAdobeFlash = true;
    };
    virtualbox.enableExtensionPack = true;
  };

}


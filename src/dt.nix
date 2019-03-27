{ config, lib, pkgs, ... }:
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
      # ./include/containers.nix FIXME
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "fuse" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8ae7ae3c-98c5-4053-b934-4e91f3407067";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F1C0-E439";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/d85d887f-9ccc-4202-893d-b18e66da10eb"; }
    ];

  nix.maxJobs = lib.mkDefault 20;

  boot.kernelParams = [
    # Use better scheduler for SSD drive
    "elevator=noop"
    "intel_pstate=disable"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  };

  hardware = {
    opengl.driSupport32Bit = true;
    enableAllFirmware = true;
    bluetooth.enable = false; # FIXME ??
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
  };

  time.timeZone = "Europe/Moscow";

  networking = {
    hostName = "darktower";

    networkmanager.enable = true;
    firewall.enable = false;
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

  services.printing = {
    enable = true;
  };

  services.xserver = {
    enable = true;

    videoDrivers = [ "nvidia" ];

    layout = "us,ru";

    xkbOptions = "grp:alt_space_toggle, ctrl:swapcaps, grp_led:caps";

    desktopManager = {
      xfce.enable = true;
    };

    displayManager = {
      lightdm.enable = true;
    };

    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  programs.ssh = {
    startAgent = true;
    askPassword = "";
    forwardX11 = true;
  };

  virtualisation.docker = {
    enable = true;
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
    enable = true;
    package = pkgs.syncthing;
    user = me;
    dataDir = "/var/lib/syncthing-${me}";
  };

  services.udev = {
    extraRules = ''
      # Android Debug Bridge identifiers
      SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="users"
    '';
  };

  services.ipfs = {
    enable = false; # FIXME
  };

  environment.systemPackages = with pkgs ; [
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    (rxvt_unicode-with-plugins.override {
      plugins = [
        urxvt_perl
        urxvt_theme_switch
      ];
    })
    myvim
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
    #skypeforlinux tarball gone
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
    gimp
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

    nvidia-docker
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
    virtualbox.enableExtensionPack = false; # FIXME
  };


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}


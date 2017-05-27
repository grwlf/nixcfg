# the system.  Help is available in the configuration.nix(5) man page
# or the NixOS manual available on virtual console 8 (Alt+F8).

{ config, pkgs, ... }:
let

  me = "grwlf";

in

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
      ./include/xfce-overrides.nix
      ./include/firefox-with-localization.nix
      # ./include/syncthing.nix
      ./include/wheel.nix
      ./include/ntpd.nix
      ./include/myprofile.nix
    ];

  # boot.kernelPackages = pkgs.linuxPackages_3_14;

  boot.blacklistedKernelModules = [
    "fbcon"

    # Debug audio
    # "snd_hda_codec_hdmi"
    # "snd_hda_codec_realtek"
    # "snd_hda_codec_generic"
    # "snd_hda_intel"
    # "snd_hda_controller"
    # "snd_hda_codec"
    # "snd_hda_core"
    # "snd_hwdep"
    # "snd_pcm_oss"
    # "snd_mixer_oss"
    # "snd_pcm"
    # "snd_timer"
    # "snd"
    # "soundcore"
    ];

  boot.kernelParams = [
    # Use better scheduler for SSD drive
    "elevator=noop"
    "intel_pstate=disable"
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

  hardware = {
    # opengl.videoDrivers = [ "vesa" ];
    opengl.driSupport32Bit = true;
    enableAllFirmware = true;
    # firmware = [ "/root/firmware" ];
    bluetooth.enable = false;
    pulseaudio.enable = true;
  };

  time.timeZone = "Europe/Moscow";

  networking = {
    hostName = "greyblade";

    networkmanager.enable = true;
  };

  fileSystems = [
    { mountPoint = "/";
      device = "/dev/disk/by-label/ROOT2";
      options = ["defaults" "relatime" "discard"];
    }
    { mountPoint = "/home";
      device = "/dev/disk/by-label/HOME";
      options = ["defaults" "relatime" "discard"];
    }
  ];

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
    package = pkgs.postgresql92;
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
    package = pkgs.syncthing012;
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

  # security = {
  #   pam = {
  #     enableEncfs = true;
  #   };
  # };

  environment.systemPackages = with pkgs ; [
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    rxvt_unicode
    vimHugeX
    glxinfo
    xcompmgr
    zathura
    xlibs.xev
    xfontsel
    xlsfonts
    djvulibre
    wine
    # libreoffice
    pidgin
    skype
    networkmanagerapplet
    pavucontrol
    qbittorrent
    cups
    mlton
    i7z

    vlc
    sox
    smplayer
    mplayer

    # (devenv {
    #   name = "dev";
    #   extraPkgs = [ haskell-latest ]
    #     ++ lib.optionals services.xserver.enable devlibs_x11;
    # })

    imagemagickBig
    geeqie
    gimp_2_8
    firefox
    encfs
    plowshare
    lsof
    google-drive-ocamlfuse
    ffmpeg
    electrum

    tdesktop
    jmtpfs
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


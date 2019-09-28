{ config, pkgs, ... }:
let

  me = "grwlf";

  ports = import ./pkgs/ports.nix;

in

rec {
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  require = [
      ./include/subpixel.nix
      ./include/haskell.nix
      ./include/bashrc.nix
      ./include/systools.nix
      ./include/fonts.nix
      ./include/user-grwlf.nix
      ./include/postfix_relay.nix
      ./include/templatecfg.nix
      ./include/xfce-overrides.nix
      ./include/wheel.nix
      ./include/ntpd.nix
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

  swapDevices = [ { device = "/dev/disk/by-label/SWAP"; } ];

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

  security.pki.certificateFiles = [
    ./certs/4BC6DC14D97010C41A26E058AD851F81C842415A.cer
    ./certs/8CAE88BBFD404A7A53630864F9033606E1DC45E2.cer
  ];

  time.timeZone = "Europe/Moscow";

  networking = {
    hostName = "greyblade";

    networkmanager.enable = true;
    firewall.enable = false;
  };

  powerManagement = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [ports.greyblade_sshd_port];
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

  services.openvpn.servers = {
    hub777_client = {
      config = ''
        client
        dev tap
        proto udp
        nobind
        ca   /root/openvpn/ca.crt
        cert /root/openvpn/grwlf.crt
        key  /root/openvpn/grwlf.key
        comp-lzo
        remote 46.38.250.132 1194
      '';
    };
  };

  programs.ssh = {
    startAgent = true;
    askPassword = "";
    forwardX11 = true;
  };

  # virtualisation.virtualbox = {
  #   host.enable = true;
  #   guest.enable = true;
  # };

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
        name="greybalde2vps";
        user=me;
        extraArguments=''
          -N -D${toString ports.greyblade_socks_port} \
          -o ServerAliveInterval=30 \
          -o ServerAliveCountMax=3 \
          -o ExitOnForwardFailure=yes \
          -p ${toString ports.vps_sshd_port} \
          grwlf@${ports.vps_ip}
        '';
      }
      {
        name = "vps2greyblade";
        user = me;
        extraArguments = ''
          -4 -N \
          -R ${toString ports.vps_greyblade_port}:127.0.0.1:${toString ports.greyblade_sshd_port} \
          -o ServerAliveInterval=30 \
          -o ServerAliveCountMax=3 \
          -o ExitOnForwardFailure=yes \
          -p ${toString ports.vps_sshd_port} \
          grwlf@${ports.vps_ip}
        '';
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
    dataDir = "/home/${me}";
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

  # services.ipfs = {
  #   enable = true;
  # };

  environment.extraInit = ''
  export NIXCFG_ROOT=\
  /home/${me}/proj/nixcfg

  export NIX_PATH=\
  nixcfg=$NIXCFG_ROOT:\
  nixpkgs=$NIXCFG_ROOT/nixpkgs:\
  nixos=$NIXCFG_ROOT/nixpkgs/nixos:\
  nixos-config=$NIXCFG_ROOT/src/samsung-np900x3c.nix:\
  '';

  environment.shellAliases = {
    nix-env = "nix-env -f '<nixpkgs>'";
  };

  environment.systemPackages = with pkgs ; [
    rxvt_unicode
    networkmanagerapplet
    pavucontrol
    glxinfo
  ];

  nixpkgs.config = {
    sox.enableLame = true;
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


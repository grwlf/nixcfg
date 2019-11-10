{ config, lib, pkgs, ... }:
let

  me = "grwlf";

  ports = import pkgs/ports.nix;

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

  fileSystems."/home/data" =
    { device = "/dev/disk/by-uuid/afb4a252-edee-4b56-8ab0-f807bdbeaecb";
      fsType = "ext4";
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
    ports = [22 ports.darktower_sshd_port];
    permitRootLogin = "yes";
    extraConfig = ''
      ClientAliveInterval 20
    '';
    gatewayPorts = "yes";
    forwardX11 = true;
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
      xfce4-14.enable = true;
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

    screenSection = ''
      Option "Coolbits" "4"
    '';
  };

  programs.ssh = {
    startAgent = true;
    askPassword = "";
    forwardX11 = true;
  };

  # programs.mosh = {
  #   enable = true;
  # };

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  services.journald = {
    extraConfig = ''
      SystemMaxUse=50M
    '';
  };

  services.autossh = {
    sessions = [
      {
        name="dt2vps";
        user=me;
        extraArguments=''
          -N -D${toString ports.darktower_socks_port} \
          -o ServerAliveInterval=30 \
          -o ServerAliveCountMax=3 \
          -o ExitOnForwardFailure=yes \
          -p ${toString ports.vps_sshd_port} \
          grwlf@${ports.vps_ip}
        '';
      }
      {
        name = "vps2dt";
        user = me;
        extraArguments = ''
          -4 -N \
          -R ${toString ports.vps_darktower_port}:127.0.0.1:${toString ports.darktower_sshd_port} \
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
    enable = true;
    package = pkgs.syncthing;
    user = me;
    dataDir = "/home/${me}";
  };

  services.udev = {
    extraRules = ''
      # Android Debug Bridge identifiers
      SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="users"
      SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="users"

      SUBSYSTEM=="usb",ATTRS{idVendor}=="1a6e",GROUP="users"
      SUBSYSTEM=="usb",ATTRS{idVendor}=="18d1",GROUP="users"
    '';
  };

  services.ipfs = {
    enable = false; # FIXME
  };

  # NIXCFG_ROOT should point to the folder where this project is checked-out
  # ~/.bash_profile may overwrite it
  environment.extraInit = ''
  export NIXCFG_ROOT=\
  /home/${me}/proj/nixcfg

  export NIX_PATH=\
  nixcfg=$NIXCFG_ROOT:\
  nixpkgs=$NIXCFG_ROOT/nixpkgs:\
  nixos=$NIXCFG_ROOT/nixpkgs/nixos:\
  nixos-config=$NIXCFG_ROOT/src/dt.nix:\
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
    # allowBroken = true;
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
  system.stateVersion = "19.03"; # Did you read the comment?

}


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let

  # FIXME: find out how to pass it to huawei-proxy.nix
  ip_addr = "10.199.192.149";

in

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  require = [
      ./include/subpixel.nix
      ./include/systools.nix
      ./include/wheel.nix
      ./include/ntpd.nix
      ./include/huawei-proxy.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/eb60af14-352d-4931-b453-114bddcf255c";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/04FD-50B1";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/HOME";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0a1855f0-ed0f-4847-a6f5-02245ef7e28a"; }
    ];

  nix.maxJobs = lib.mkDefault 28;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  boot.loader.systemd-boot.enable = true;

  networking.networkmanager.enable = false;
  networking.hostName = "mrc-cbg-02";
  networking.defaultGateway.address = "10.199.192.129";
  networking.dhcpcd.enable = false;
  networking.firewall.enable = false;
  networking.interfaces."enp0s31f6".ipv4.addresses = [
    { address = ip_addr; prefixLength = 25; }
  ];
  networking.nameservers = [
    "10.129.29.84"
    "10.129.29.85"
  ];

  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  services.openssh = {
    enable = true;
    ports = [22];
    permitRootLogin = "yes";
    extraConfig = ''
      ClientAliveInterval 20
    '';
  };

  services.xserver = {
    enable = true;

    videoDrivers = [ "nvidia" ];

    layout = "us,ru";

    #xkbOptions = "grp:alt_space_toggle, ctrl:swapcaps, grp_led:caps";

    desktopManager = {
      xfce4-14.enable = true;
    };

    windowManager = {
      awesome.enable = true;
      awesome.luaModules = [
          pkgs.luaPackages.vicious
        ];
    };

    displayManager = {
      lightdm.enable = true;
      lightdm.extraSeatDefaults = "xserver-allow-tcp=true";
      lightdm.extraConfig = ''
      [XDMCPServer]
      enabled=true
      port=177
      '';
      xserverArgs = [ "-listen tcp" ];

      # session = [
      #   {
      #     manage = "window";
      #     name = "custom-awesome";
      #     start = ''
      #       ${pkgs.awesome}/bin/awesome &
      #       waitPID=$!
      #     '';
      #   }
      # ];
    };

    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';

    enableTCP = true;
  };

  services.xrdp = {
    enable = true;
    # defaultWindowManager = ". ~/startwm.sh";
  };

  programs.adb = {
    enable = true;
  };

  users.extraUsers =
    let
      mkuser = name : id : {
        "${name}" = {
          uid = id;
          isNormalUser = true;
          extraGroups = ["docker" "adbusers"];
          initialPassword = "huawei123";
        };
      };
    in
    (mkuser "mironov" 1048) //
    (mkuser "grechanik" 1050) //
    (mkuser "khalikov" 1070) //
    (mkuser "romanov" 1071) //
    (mkuser "murygin" 1072) //
    {
      "data" = {
        uid = 2000;
        group = "users";
        home = "/home/data/";
        createHome = true;
        isNormalUser = false;
        extraGroups = [];
      };
    };

  hardware = {
    opengl.driSupport32Bit = true;
    enableAllFirmware = true;
  };

  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };

  # NIXCFG_ROOT should point to the folder where this project is checked-out
  # ~/.bash_profile may overwrite it
  environment.extraInit = ''
  export NIXCFG_ROOT=\
  /home/nixcfg

  export NIX_PATH=\
  nixcfg=$NIXCFG_ROOT:\
  localpkgs=$NIXCFG_ROOT/src/pkgs/localpkgs.nix:\
  nixpkgs=$NIXCFG_ROOT/nixpkgs:\
  nixos=$NIXCFG_ROOT/nixpkgs/nixos:\
  nixos-config=$NIXCFG_ROOT/src/mrc-cbg-2.nix:\
  '';

  environment.shellAliases = {
    nix-env = "nix-env -f '<nixpkgs>'";
  };

  # Rules for Coral Accelerator
  services.udev = {
    extraRules = ''
      SUBSYSTEM=="usb",ATTRS{idVendor}=="1a6e",GROUP="users"
      SUBSYSTEM=="usb",ATTRS{idVendor}=="18d1",GROUP="users"
    '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    unclutter
    xorg.xdpyinfo
    xorg.xinput
    (rxvt_unicode-with-plugins.override {
      plugins = [
        urxvt_perl
        urxvt_theme_switch
      ];
    })
    glxinfo
    networkmanagerapplet
    chromium
    plowshare
    lsof
    evince
    vim
    nvtop
  ];

  nixpkgs.config.allowUnfree = true;

}

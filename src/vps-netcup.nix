# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  me = "grwlf";

  ports = import ./pkgs/ports.nix;

in
rec {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./include/bashrc.nix
    ./include/systools.nix
    ./include/postfix_relay.nix
    ./include/templatecfg.nix
    ./include/user-grwlf.nix
    ./include/wheel.nix
    ./include/ntpd.nix
    ./include/overrides.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  fileSystems = [
    { mountPoint = "/home";
      device = "/dev/disk/by-label/HOME";
    }
  ];

  networking = {

    hostName = "vps";
    wireless.enable = false;
    enableIPv6 = false;

    firewall = {
      enable = true;
      allowPing = true;
      allowedUDPPorts = [
        1194 # openvpn
        34730 34731 # mosh
      ];
      allowedTCPPorts = [
        80
        8080
        443
      ];
    };

    nat = {
      enable = true;
      internalInterfaces = [ "tun0" ];
      internalIPs = [ "10.0.0.0/24" ];
      externalInterface = "ens3";
    };
  };

  programs = {
    ssh = {
      setXAuthLocation = true;
    };
  };

  services.openssh.enable = true;
  services.openssh.ports = [ports.vps_sshd_port];
  services.openssh.permitRootLogin = "no";
  services.openssh.gatewayPorts = "yes";
  services.openssh.forwardX11 = true;

  services.postgresql = {
    enable = true;
    # package = pkgs.postgresql92;
  };

  services.xserver.enable = false;

  services.httpd = {
    enable = true;
    adminAddr = "grrwlf@gmail.com";
    logPerVirtualHost = true;
    virtualHosts = [
      # {
      #   hostName = "sthdwp.com";
      #   globalRedirect = "http://hit.msk.ru:8080/";
      # }
      {
        hostName = "sthdwp.com";
        extraConfig = ''
          ProxyPreserveHost On
          ProxyRequests Off
          ServerName sthdwp.com
          ServerAlias www.sthdwp.com
          ProxyPassMatch "^/$" http://127.0.0.1:8080
          ProxyPassMatch "^.*$" http://127.0.0.1:8080
          ProxyPassReverse / http://127.0.0.1:8080/
        '';
      }

      {
        hostName = "vocal.sthdwp.com";
        globalRedirect = "http://sthdwp.com:8081/";
      }

      {
        hostName = "archerydays.ru";
        extraConfig = ''
          ProxyPreserveHost On
          ProxyRequests Off
          ServerName www.archerydays.ru
          ServerAlias archerydays.ru
          ProxyPassMatch "^/$" http://127.0.0.1:8080/Etab/main
          ProxyPassMatch "^.*$" http://127.0.0.1:8080
          ProxyPassReverse / http://127.0.0.1:8080/
        '';
      }
    ];
  };


  services.haproxy = {
    enable = true;
    config = ''

      backend secure_http
          reqadd X-Forwarded-Proto:\ https
          rspadd Strict-Transport-Security:\ max-age=31536000
          mode http
          option httplog
          option forwardfor
          server local_http_server 127.0.0.1:80

      backend ssh
          mode tcp
          option tcplog
          server ssh 127.0.0.1:${toString ports.vps_sshd_port}
          timeout tunnel 600s

      frontend ssl
          bind 0.0.0.0:443 ssl crt ${../ideas/stunnel-test/stunnel.pem} no-sslv3
          mode tcp
          option tcplog
          tcp-request inspect-delay 5s
          tcp-request content accept if HTTP

          acl client_attempts_ssh payload(0,7) -m bin 5353482d322e30

          use_backend ssh if !HTTP
          use_backend ssh if client_attempts_ssh
          use_backend secure_http if HTTP
    '';
  };

  services.syncthing ={
    enable = true;
    package = pkgs.syncthing;
    user = "syncthing";
    dataDir = "/home/syncthing";
  };

  services.openvpn.servers = {
    myserver = {
      config = let
        pwfile = pkgs.writeText "openvpn-management-pwfile"
                                (import <nixcfg/passwords/openvpn-management>);
      in ''
        port 1194
        proto udp
        dev tun
        keepalive 10 120
        comp-lzo
        client-to-client

        ca   /root/openvpn/ca.crt
        key  /root/openvpn/hub777.key # This file should be kept secret.
        cert /root/openvpn/hub777.crt
        dh   /root/openvpn/dh.pem

        server 10.0.0.0 255.255.255.0

        user nobody
        group nogroup

        management 127.0.0.1 5555 ${pwfile}
      '';
    };
  };

  environment.extraInit = ''
  export NIXCFG_ROOT=\
  /home/${me}/proj/nixcfg

  export NIX_PATH=\
  nixcfg=$NIXCFG_ROOT:\
  nixpkgs=$NIXCFG_ROOT/nixpkgs:\
  nixos=$NIXCFG_ROOT/nixpkgs/nixos:\
  nixos-config=$NIXCFG_ROOT/src/vps-netcup.nix:\
  '';

  environment.systemPackages = with pkgs ; [
    # myvim
    # postgresql
    # imagemagick
    # mlton
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };
}

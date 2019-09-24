{ pkgs ? import <nixpkgs> {} } :

let
  ports = import ./ports.nix;
in
with ports;
pkgs.writeText "ssh_config" ''
  Host vps
      HostName ${vps_ip}
      User grwlf
      Port ${toString vps_sshd_port}
      ForwardX11 yes
      ForwardX11Trusted  yes

  Host goodfellow
      ProxyCommand ssh vps nc 127.0.0.1 ${toString vps_goodfellow_port}
      ForwardX11         yes
      ForwardX11Trusted  yes

  Host phone
      User user
      HostName RM696.local

  host dv
      User grwlf
      HostName ${dv_ip}
      Port  ${toString dv_sshd_port}
      ForwardX11         yes
      ForwardX11Trusted  yes

  Host dt
      ProxyCommand ssh vps nc 127.0.0.1 ${toString vps_darktower_port}
      ForwardX11         yes
      ForwardX11Trusted  yes
  ''

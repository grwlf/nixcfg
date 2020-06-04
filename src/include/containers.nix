{ config, pkgs, ... } :
let

  mykey = import <nixcfg/passwords/pubkey>;

  template = index : programs : {
    users.users = {
      banker = {
        home = "/home/banker";
        uid = 10000 + index;
        createHome = true;
        hashedPassword = import <nixcfg/passwords/banker>;
        shell = pkgs.bash;
        openssh.authorizedKeys.keys = [ mykey ];
      };

      root.openssh.authorizedKeys.keys = [ mykey ];
    };

    services.openssh =
      let
        port = 22200+index;
      in {
        enable = true;
        permitRootLogin = "yes";
        passwordAuthentication = true;
        forwardX11 = true;
        ports = [ port ];
        listenAddresses = [ { addr = "127.0.0.1" ; port = port ; } ];
        logLevel = "VERBOSE";
      };

    environment.systemPackages = (with pkgs ; [
      xorg.xeyes
    ]) ++ programs;

    environment.extraInit = ''
      export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:$LD_LIBRARY_PATH"
    '';

  };

in {

  containers.crypto-geth = {
    config = { config, pkgs, ... }: template 1 (with pkgs; [go-ethereum]);
  };

  containers.crypto-btc = {
    config = {config, pkgs, ... }: template 2 (with pkgs; [electrum]);
    bindMounts = { "/run/opengl-driver/lib" = { hostPath = "/run/opengl-driver/lib"; isReadOnly = true; } ; };
  };

  containers.crypto-bcc = {
    config = {config, pkgs, ... }: template 3 (with pkgs; [electron-cash]);
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "cgeth" ''
      sudo -E nixos-container start crypto-geth
      ssh -Y -l banker -p 22201 127.0.0.1
    '')
    (pkgs.writeShellScriptBin "cbtc" ''
      sudo nixos-container start crypto-btc
      ssh -Y -l banker -p 22202 127.0.0.1
    '')
    (pkgs.writeShellScriptBin "cbcc" ''
      sudo nixos-container start crypto-bcc
      ssh -Y -l banker -p 22203 127.0.0.1
    '')
  ];

}


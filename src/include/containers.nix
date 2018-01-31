{ config, pkgs, ... } :
let

  mykey = import <passwords/pubkey>;

  template = index : programs : {
    users.users = {
      banker = {
        home = "/home/banker";
        uid = 10000 + index;
        createHome = true;
        hashedPassword = import <passwords/banker>;
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
        permitRootLogin = "no";
        passwordAuthentication = true;
        forwardX11 = true;
        ports = [ port ];
        listenAddresses = [ { addr = "127.0.0.1" ; port = port ; } ];
      };

    environment.systemPackages = (with pkgs ; [
        nvi
    ]) ++ programs;
  };

in {

  containers.crypto-geth = {
    config = { config, pkgs, ... }: template 1 (with pkgs; [go-ethereum]);
  };

  containers.crypto-btc = {
    config = {config, pkgs, ... }: template 2 (with pkgs; [electrum]);
  };

  containers.crypto-bcc = {
    config = {config, pkgs, ... }: template 3 (with pkgs; [electron-cash]);
  };

  environment.extraInit = ''
    cgeth() {
      sudo nixos-container start crypto-geth
      ssh -Y -l banker -p 22201 127.0.0.1
    }
    cbcc() {
      sudo nixos-container start crypto-bcc
      ssh -Y -l banker -p 22203 127.0.0.1
    }
    cbtc() {
      sudo nixos-container start crypto-btc
      ssh -Y -l banker -p 22202 127.0.0.1
    }
  '';

}


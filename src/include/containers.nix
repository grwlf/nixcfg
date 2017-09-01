{ config, pkgs, ... } :
let

  mykey = import <passwords/pubkey>;

  template = index : {
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

  };

in {

  containers.crypto-geth = {
    config = { config, pkgs, ... }: (template 1) // {

      environment.systemPackages = with pkgs ; [
        go-ethereum
      ];
    };
  };

  containers.crypto-btc = {
    config = {config, pkgs, ... }: (template 2) // {

      environment.systemPackages = with pkgs ; [
        electrum # bitcoin wallet
      ];

    };

  };

  containers.crypto-bcc = {
    config = {config, pkgs, ... }: (template 3) // {

      environment.systemPackages = with pkgs ; [
        electron-cash
      ];

    };

  };

}


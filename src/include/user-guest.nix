{ config, pkgs, ... } :
{

  users.extraUsers = {
    guest = {
      uid = 2000;
      group = "guest";
      home = "/home/guest";
      useDefaultShell = true;
    };
  };

}


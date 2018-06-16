{ config, pkgs, ... } :
{

  users.extraUsers =
  let
    hasnm = config.networking.networkmanager.enable;
  in {

    grwlf = {
      uid = 1000;
      group = "users";
      extraGroups = ["wheel" "audio" "vboxusers" "docker"]
        ++ pkgs.lib.optional hasnm "networkmanager"
        ;
      home = "/home/grwlf";
      useDefaultShell = true;
      hashedPassword = "$6$9dn4y26D$H36bBsHtk/3okozUbJW2oA3BFtZGwMBd4UrR3nxst1sKIYj.xgg4qryBVDVt3zT0wtigM28eeeJxW5V96Ft7n.";
    };

  };


}


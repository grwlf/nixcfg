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
    };

  };


}


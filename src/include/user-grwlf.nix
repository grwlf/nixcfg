{ config, pkgs, ... } :
{

  users.extraUsers =
  let
    hasvb = pkgs.lib.elem config.boot.kernelPackages.virtualbox config.environment.systemPackages;
    hasnm = config.networking.networkmanager.enable;
  in {

    grwlf = {
      uid = 1000;
      group = "users";
      extraGroups = ["wheel" "audio"]
        ++ pkgs.lib.optional hasnm "networkmanager"
        ++ pkgs.lib.optional hasvb "vboxusers";
      home = "/home/grwlf";
      useDefaultShell = true;
    };

  };


}


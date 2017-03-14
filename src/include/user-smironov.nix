{ config, pkgs, ... } :
{

  users.extraUsers =
  let
    hasvb = pkgs.lib.elem config.boot.kernelPackages.virtualbox config.environment.systemPackages;
    hasnm = config.networking.networkmanager.enable;
  in {
    smironov = {
      uid = 1000;
      group = "users";
      extraGroups = ["wheel" "audio" "docker"]
        ++ pkgs.lib.optional hasnm "networkmanager"
        ++ pkgs.lib.optional hasvb "vboxusers";
      home = "/home/smironov";
      useDefaultShell = true;
    };
  };

}


{ config, pkgs, ... } :
{

  security = {
    sudo.configFile = ''
      Defaults !pwfeedback
      Defaults:root,%wheel env_keep+="NIX_PATH _NIXOS_REBUILD_REEXEC"
    '';
  };

}

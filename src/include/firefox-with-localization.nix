{ config, pkgs, ... } :
{
  nixpkgs.config = {

    packageOverrides = pkgs : {
      firefox = pkgs.writeShellScriptBin "firefox" ''
        ${pkgs.firefox}/bin/firefox -UILocale ru "$@"
      '';
    };

  };

}

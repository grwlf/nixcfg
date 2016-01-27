{ config, pkgs, ... } :
{
  nixpkgs.config = {

    packageOverrides = pkgs : {
      firefox-langpack = pkgs.callPackage ../pkgs/firefoxLocaleWrapper.nix {language = "ru";};
    };

  };

}

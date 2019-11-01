{ me
, pkgs ? import <nixpkgs> {}
, localpkgs ? import <nixcfg/src/pkgs/localpkgs.nix> {inherit pkgs me;}
} :
let
  inherit (localpkgs) pkgs placeTo;
in
pkgs.buildEnv {
  name = "myenv";
  paths = with localpkgs; [
    myvim
    myprofile
    mysshconfig
    rxvt_unicode
  ];
}


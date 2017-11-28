{ config, pkgs, ... } :

{
  environment.etc."cvimrc".source = ../cfg/cvimrc;
}

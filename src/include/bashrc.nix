{ config, pkgs, ... } :

{
  environment = rec {

    extraInit = ''
      if test -f /etc/myprofile ; then
        . /etc/myprofile
      fi
    '';
  };

  programs = {

    bash = {

      promptInit = ''
        PROMPT_COLOR="1;31m"
        let $UID && PROMPT_COLOR="1;32m"
        PS1="\n\[\033[$PROMPT_COLOR\][\u@\h \w ]\\$\[\033[0m\] "
      '';

      enableCompletion = true;
    };
  };

  environment.etc."myprofile".source = pkgs.myprofile;

}


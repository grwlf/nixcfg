{ config, pkgs, ... } :

{
  programs = {

    bash = {

      enableCompletion = true;

      promptInit = ''
        PROMPT_COLOR="1;31m"
        let $UID && PROMPT_COLOR="1;32m"
        PS1="\n\[\033[$PROMPT_COLOR\][\u@\h \w ]\\$\[\033[0m\] "
      '';

      # interactiveShellInit = ''
      #   if test -f /etc/myprofile ; then
      #     . /etc/myprofile
      #   fi
      # '';
    };
  };

  # environment.etc."myprofile".source = pkgs.myprofile;

}


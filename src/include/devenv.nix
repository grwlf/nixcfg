{ config, pkgs, ... } :

let

  devlibs_x11 = with pkgs ; [
    freetype
    fontconfig
    xlibs.xproto
    xlibs.libX11
    xlibs.libXt
    xlibs.libXft
    xlibs.libXext
    xlibs.libSM
    xlibs.libICE
    xlibs.xextproto
    xlibs.libXrender
    xlibs.renderproto
    xlibs.libxkbfile
    xlibs.kbproto
    xlibs.libXrandr
    xlibs.randrproto
  ];

  devlibs_cross = with pkgs; [
    i386_toolchain.gcc
    i386_toolchain.binutils
    i386_toolchain.gdb
    arm_toolchain_bare.gcc
    arm_toolchain_bare.binutils
    arm_toolchain_bare.gdb
    avr_toolchain.gcc
    avr_toolchain.binutils
    avr_toolchain.gdb
  ];

  common = with pkgs; [
    autoconf
    automake
    gettext
    flex
    bison
    intltool
    libtool
    pkgconfig
    curl
    sqlite
    postgresql92
    cmake
    python
    ncurses
    curl
    zlib
    patchelf
    m4
    gtk_doc
    glib
    gdb
    gmp
    mpfr
    gcc
    mlton
    stack
  ];

in

{
  nixpkgs.config = {

    packageOverrides = pkgs : {

      inherit devlibs_x11 devlibs_cross;

      devenv = { name ? "dev", extraPkgs ? []} :
        let

          myprofile = import ./myprofile.nix {
            inherit pkgs;
            extra = ''
              PROMPT_COLOR="0;35m"
              PS1="\n\[\033[$PROMPT_COLOR\][\u@\h-${name} \w ]\\$\[\033[0m\] "
              export LANG=en_US.UTF8
              export LD_LIBRARY_PATH="${pkgs.curl}/lib:${pkgs.openssl}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH"
            '';
          };

        in

        pkgs.myEnvFun {
          inherit name;
          buildInputs = with pkgs.stdenv.lib; common ++ extraPkgs;
          shell = "${pkgs.bashInteractive}/bin/bash --noprofile --rcfile ${myprofile}";
        };

    };
  };

}

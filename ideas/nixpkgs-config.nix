{
  allowUnfree = true;
  allowBroken = true;

  packageOverrides = pkgs:
    let
      inherit (pkgs) stdenv;
    in
    with pkgs; {

    rdev = pkgs.rWrapper.override {
      packages = with pkgs.rPackages; [
        devtools
        ggplot2
        reshape2
        yaml
        optparse
      ];
    };

    pydev = stdenv.mkDerivation {
      name = "pydev";
      buildInputs = with python3Packages; [
        python
        scipy
        numpy
        matplotlib
        xlibs.xeyes
        pycairo
        pyqt5
        pygobject3
        gtk3
        gobjectIntrospection
        ipython
      ];

      shellHook = ''
        export MPLBACKEND='Qt5Agg'
      '';
    };

    odev = stdenv.mkDerivation {
      name = "odev";
      buildInputs = [
        octave
        gnuplot
      ];
    };

  };
}

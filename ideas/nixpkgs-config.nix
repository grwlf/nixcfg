{
  allowUnfree = true;
  allowBroken = true;

  packageOverrides = pkgs:
    with pkgs; {

    rEnv = pkgs.rWrapper.override {
      packages = with pkgs.rPackages; [
        devtools
        ggplot2
        reshape2
        yaml
        optparse
      ];
    };

    pydev = pkgs.stdenv.mkDerivation {
      name = "pydev";
      buildInputs = with python3Packages; [
        python
        scipy
        numpy
        matplotlib
      ];
    };

  };
}

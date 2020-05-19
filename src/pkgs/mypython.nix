{ pkgs ? import <nixpkgs> {} } :

with pkgs;
let
  my-python-packages = pp: with pp; [
    ipython
    requests
    matplotlib
    pandas
    numpy
  ];
  python-with-my-packages = python3.withPackages my-python-packages;
in
  pkgs.writeShellScriptBin "myipython" ''
    ${python-with-my-packages}/bin/ipython -c '
      from pandas import DataFrame
      from numpy import array
      import numpy as np;
      import pandas as pd;
      import matplotlib.pyplot as plt;
    ' -i "$@"
  ''

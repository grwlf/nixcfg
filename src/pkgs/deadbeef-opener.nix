{ stdenv, writeText }:
stdenv.mkDerivation {
  name = "deadbeef-opener";

  builder = writeText "builder.sh" ''
    . $stdenv/setup
    mkdir -pv $out/bin
    cp ${./deadbeef-opener.sh} $out/bin/deadbeef-opener.sh
    chmod +x $out/bin/*
  '';
}


{ stdenv, postfix, writeText, coreutils, ... } :
let

  p = import <nixcfg/passwords/gmail>;

in stdenv.mkDerivation {
  name = "sasl_passwd";
  builder = writeText "builder.sh" ''
    ${coreutils}/bin/mkdir $out
    echo '[smtp.gmail.com]:587 grrwlf@gmail.com:${p}' > $out/sasl_passwd
    ${coreutils}/bin/chmod 600 $out/sasl_passwd
  '';
}

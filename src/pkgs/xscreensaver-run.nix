{ stdenv, fetchgit, libX11, xscreensaver, makeWrapper}:

stdenv.mkDerivation rec {
  name = "xscreensaver-run-${version}";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/grwlf/xscreensaver-run";
    rev = "c277a6ca6c49f2609ff693e4b6bd64784bab1d6e";
    sha256 = "sha256:1im9kyzf7vpz1682mn9c8pvqi8d5x5grr4w8gbgbh4q0cmddq5s8";
  };

  nativeBuildInputs = [ ];
  buildInputs = [ libX11 xscreensaver makeWrapper ];
  makeFlags=[ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram "$out/bin/xscreensaver-run" \
      --prefix PATH : "${xscreensaver}/libexec/xscreensaver"
    '';

  meta = with stdenv.lib; {
    description = "Run screensaver from XScreenSaver collection synchronousely";
    homepage = https://github.com/grwlf/xscreensaver-run;
    license = licenses.mit;
    maintainers = with maintainers; [ smironov ];
    platforms = platforms.linux;
  };
}



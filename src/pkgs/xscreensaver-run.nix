{ stdenv, fetchgit, fetchFromGitHub, libX11, xscreensaver, makeWrapper}:

stdenv.mkDerivation rec {
  name = "xscreensaver-run-${version}";
  version = "1.0.0";

  # src = fetchgit {
  #   url = "https://github.com/grwlf/xscreensaver-run";
  #   rev = "b722de024dacf65cf714539cc146fed1c82efab6";
  #   sha256 = "sha256:1c5j1qapmfbddf5xr88j19bf8rwayhdsq7iybhb09zgk1443cbra";
  # };
  src = fetchFromGitHub {
    owner = "grwlf";
    repo = "xscreensaver-run";
    rev = "ce1b7b2829240585e9518b6b4fb3fa3e7fe6f0a8";
    sha256 = "sha256:161habpfhqzfhgmxvlcy8xqswari6hm7csn1hgp0afyzrv63hv74";
  };

  nativeBuildInputs = [ ];
  buildInputs = [ libX11 xscreensaver makeWrapper ];
  makeFlags=[ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram "$out/bin/xscreensaver-run" \
      --prefix PATH : "${xscreensaver}/libexec/xscreensaver" \
      --prefix PATH : "${xscreensaver}/bin"
    '';

  meta = with stdenv.lib; {
    description = "Run screensaver from XScreenSaver collection synchronousely";
    homepage = https://github.com/grwlf/xscreensaver-run;
    license = licenses.mit;
    maintainers = with maintainers; [ smironov ];
    platforms = platforms.linux;
  };
}



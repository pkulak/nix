{ stdenv, fetchFromGitHub, ... }:

let
  pname = "toolgit";
  version = "20241105";

  src = fetchFromGitHub {
    owner = "ahmetsait";
    repo = "toolgit";
    rev = "a6818362cef46bf25a0b3eece356030666b2bdc1";
    sha256 = "sha256-DdS385QMqu0ZOK5X4VTGGFyKd2xG3jpqmJM7hTkMsRk=";
  };

in stdenv.mkDerivation {
  inherit pname version src;

  installPhase = ''
    mkdir -p $out/bin

    for f in git-*; do
      install --mode 755 $f $out/bin 
    done
  '';
}

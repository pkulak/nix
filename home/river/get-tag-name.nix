{ python3, stdenv, ... }:

stdenv.mkDerivation {
  name = "get-tag-name";
  propagatedBuildInputs = [ python3 ];
  dontUnpack = true;
  installPhase = "install -Dm755 ${./get-tag-name.py} $out/bin/get-tag-name";
}

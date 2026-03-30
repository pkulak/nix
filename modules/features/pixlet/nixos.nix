{ stdenv
, fetchurl
, gnutar
, autoPatchelfHook
, glibc
, ...
}:

let
  pname = "pixlet";
  version = "0.22.4";

  src = fetchurl {
    url = "https://github.com/tidbyt/pixlet/releases/download/v${version}/pixlet_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-peZd7d47IWB81utAMnlp85O2SMnD0i35wApG78kZXrs=";
  };

in
  stdenv.mkDerivation rec {
    inherit pname version src;

    nativeBuildInputs = [
      gnutar
      autoPatchelfHook
    ];

    buildInputs = [
      glibc
    ];

    unpackPhase = ''
      tar xfz $src
    '';

    installPhase = ''
      install -m755 -D pixlet $out/bin/pixlet
    '';
  }

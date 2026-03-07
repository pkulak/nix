{ acl
, lib
, fetchurl
, pkg-config
, gcc15Stdenv
, util-linux
, ...
}:
gcc15Stdenv.mkDerivation rec {
  pname = "jai";
  version = "0.2";

  src = fetchurl {
    url = "https://github.com/stanford-scs/jai/releases/download/v${version}/jai-${version}.tar.gz";
    hash = "sha256-neFe7Mxx+kKSReMPCeON4cWdAil7vjRUVb2fqnVT9iI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ util-linux acl ];

  env.NIX_CFLAGS_COMPILE = "-Wno-unused-result";
  configureFlags = [ "--prefix=${placeholder "out"}" ];

  doCheck = false;

  meta = with lib; {
    description = "Light-weight sandbox for AI agents";
    homepage = "https://jai.scs.stanford.edu/";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "jai";
  };
}

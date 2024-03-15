{ fetchFromSourcehut
, pkg-config
, river
, stdenv
, wayland
, wayland-protocols
, zig_0_11
, ...}:

stdenv.mkDerivation {
  pname = "river-bedload";
  version = "2024-03-14";

  src = fetchFromSourcehut {
    owner = "~novakane";
    repo = "river-bedload";
    rev = "9cdc0e0f7a2b39dd10675fb7cdaed6dac401ba39";
    fetchSubmodules = true;
    hash = "sha256-K3CXJjOW/oXKlVFBahTNtCTYMps0TnygRkp60lnDPlo=";
  };

  nativeBuildInputs = [
    pkg-config
    river
    wayland
    wayland-protocols
    zig_0_11.hook
  ];

  meta = {
    homepage = "https://git.sr.ht/~novakane/river-bedload";
    description = "Display information about river in json in the STDOUT.";
  };
}

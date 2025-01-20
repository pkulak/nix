{ lib, stdenv, callPackage, fetchFromSourcehut, pkg-config, river, wayland
, wayland-protocols, wayland-scanner, zig_0_13, ... }:

stdenv.mkDerivation (finalAttrs: {
  pname = "river-bedload";
  version = "0.1.1";

  src = fetchFromSourcehut {
    owner = "~novakane";
    repo = "river-bedload";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-AMxFdKVy4E1xVdimqxm8KZW39krk/Mt27MWLxEiq1JA=";
  };

  nativeBuildInputs =
    [ pkg-config river wayland wayland-protocols wayland-scanner zig_0_13.hook ];

  postPatch = ''
    cp -a ${callPackage ./deps.nix { }}/. $ZIG_GLOBAL_CACHE_DIR/p
  '';

  meta = with lib; {
    homepage = "https://git.sr.ht/~novakane/river-bedload";
    description = "Print river compositor info in STDOUT";
    changelog =
      "https://git.sr.ht/~novakane/river-debload/refs/v${finalAttrs.version}";
    license = licenses.gpl3Plus;
    inherit (zig_0_13.meta) platforms;
    mainProgram = "river-bedload";
  };
})

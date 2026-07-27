{
  lib,
  fetchurl,
  makeWrapper,
  nodejs,
  stdenvNoCC,
  ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "pi-agent-browser-native";
  version = "0.2.72";

  src = fetchurl {
    url = "https://registry.npmjs.org/pi-agent-browser-native/-/pi-agent-browser-native-${version}.tgz";
    hash = "sha256-3subgZHSxRN4wigNrM0KO6o2QmNSr8PtdrT4mg2kRlE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    tar -xzf "$src" --strip-components=1
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out" "$out/bin"
    cp -R package.json dist scripts docs README.md CHANGELOG.md LICENSE platform-smoke.config.mjs "$out"/

    makeWrapper ${lib.getExe nodejs} "$out/bin/pi-agent-browser-config" \
      --add-flags "$out/scripts/config.mjs"
    makeWrapper ${lib.getExe nodejs} "$out/bin/pi-agent-browser-doctor" \
      --add-flags "$out/scripts/doctor.mjs"

    runHook postInstall
  '';

  meta = {
    description = "Native pi extension that exposes agent-browser as a tool";
    homepage = "https://github.com/fitchmultz/pi-agent-browser-native";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}

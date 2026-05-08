{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  stdenvNoCC,
  ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "pi-agent-browser-native";
  version = "0.2.22";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-agent-browser-native";
    rev = "v${version}";
    hash = "sha256-8jhELo5h1bqHE8Ldpwl7ZnH6atM6LZm15x3mHQyYhLM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out" "$out/bin"
    cp -R package.json extensions scripts docs README.md CHANGELOG.md LICENSE "$out"/

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

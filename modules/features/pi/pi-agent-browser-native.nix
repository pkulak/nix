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

    playbook="$out/dist/extensions/agent-browser/lib/playbook.js"
    for prompt in \
      'Use agent_browser for real browser or live web content.' \
      'Prefer agent_browser over bash, osascript, AppleScript, or generic browser-driving shell for sites, docs, clicking, filling, screenshots, eval, and batch workflows.' \
      'Project rule: when browser automation is needed, prefer the native `agent_browser` tool. Do not run direct `agent-browser` bash commands unless the user explicitly asks for a bash-oriented workflow or browser-integration debugging.'
    do
      if ! grep -Fq -- "$prompt" "$playbook"; then
        echo "pi-agent-browser-native changed its browser-first prompt guidance." >&2
        echo "Update extensions/http-tool-guidance.ts before upgrading." >&2
        exit 1
      fi
    done

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

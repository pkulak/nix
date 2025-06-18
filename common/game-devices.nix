{
  stdenvNoCC,
  fetchFromGitea,
  ...
}:
stdenvNoCC.mkDerivation {
  name = "game-devices";
  version = "20250618";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "fabiscafe";
    repo = "game-devices-udev";
    rev = "0060b94062f1af8b00c6a9d5496e054f986c3626";
    sha256 = "sha256-b2NBgGpRQ2pQZYQgiRSAt0loAxq1NEByRHVkQQRDOj0=";
  };

  installPhase = ''
    rm 71-powera*
    mkdir -p $out/lib/udev/rules.d
    cp *.rules $out/lib/udev/rules.d/
  '';
}

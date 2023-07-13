{ lib
, libappindicator
, rustPlatform
, fetchFromGitHub
, pkg-config
, atk
, cairo
, gdk-pixbuf
, glib
, gtk3
, openssl_1_1
, pango
, stdenv
, darwin
, ...
}:

rustPlatform.buildRustPackage rec {
  pname = "buzz";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "jonhoo";
    repo = "buzz";
    rev = "v${version}";
    hash = "sha256-k3tAZ88ppG9eas2LPLN/RiTCAoQ1FxoVtZFiAbaj8+o=";
  };

  cargoHash = "sha256-zGRS4XuDGDsuvc/JIzVqROkvuEtIoJn3XPdWZwNUM9s=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    libappindicator
    openssl_1_1
    pango
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "A simple system tray application for notifying about unseen e-mail";
    homepage = "https://github.com/jonhoo/buzz";
    license = with licenses; [ mit asl20 ];
    maintainers = with maintainers; [ ];
  };
}

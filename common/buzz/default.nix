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
, openssl
, pango
, stdenv
, darwin
, ...
}:

rustPlatform.buildRustPackage rec {
  pname = "buzz";
  version = "unstable-2022-09-03";

  src = fetchFromGitHub {
    owner = "jonhoo";
    repo = "buzz";
    rev = "07cf74e3863f01213e37488926e7dc07e9ac004f";
    hash = "sha256-lzr+DS8UpKkzUxXRjEXD/U6HyRkaM/Q7GFfAM2PJXYw=";
  };

  cargoHash = "sha256-6zQ5bYehTgCdUwEawDUqmxKdJNrcdVbKuy5Bp20hFoc=";

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
    openssl
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

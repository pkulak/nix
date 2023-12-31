{ lib
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, darwin
, pkgs-unstable
, ...
}:

pkgs-unstable.rustPlatform.buildRustPackage rec {
  pname = "matui";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "pkulak";
    repo = "matui";
    rev = "v${version}";
    hash = "sha256-B3N1Kq3/cjyCgsNrh8r53GYqB2KaXAWg8xIj79hbK6g=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "matrix-sdk-0.6.2" = "sha256-uV+pKHrAvApNrynyzQgxDCPZ3RKMO2FviBL4n+RDPzc=";
      "ruma-0.8.2" = "sha256-tgqUqiN6LNUyz5I6797J0YFsiFyYWfexa7n2jwUoHWA=";
      "vodozemac-0.3.0" = "sha256-tAimsVD8SZmlVybb7HvRffwlNsfb7gLWGCplmwbLIVE=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Foundation
    darwin.apple_sdk.frameworks.Security
  ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/pkulak/matui";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
  };
}

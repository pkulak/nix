{ lib
, buildGoModule
, fetchFromGitHub
, ...
}:

buildGoModule {
  pname = "ffmpeg-over-ip-client";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "steelbrain";
    repo = "ffmpeg-over-ip";
    rev = "v5.0.0";
    hash = "sha256-SM8IZeLUW0i/4qQ/7eHzrKKrALeXcUtigQId1KHqlls=";
  };

  subPackages = [ "cmd/client" ];

  vendorHash = null;

  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/client $out/bin/ffmpeg-over-ip-client
    ln -s $out/bin/ffmpeg-over-ip-client $out/bin/ffmpeg-over-ip-ffprobe
  '';

  meta = with lib; {
    description = "Remote GPU-accelerated ffmpeg client";
    homepage = "https://github.com/steelbrain/ffmpeg-over-ip";
    license = licenses.mit;
  };
}
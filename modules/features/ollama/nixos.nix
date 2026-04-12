{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [ "qwen2.5-coder:7b" ];
    acceleration = "rocm";
    host = "0.0.0.0";
  };

  networking.firewall.allowedTCPPorts = [ 11434 ];
}

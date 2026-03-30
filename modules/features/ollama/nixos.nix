{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [ "dolphin-mistral:7b" ];
    acceleration = "rocm";
  };
}

{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.unstable.agent-browser

    (pkgs.symlinkJoin {
      name = "pi-coding-agent";
      nativeBuildInputs = [ pkgs.makeWrapper ];
      paths = [ pkgs.unstable.pi-coding-agent ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --set NPM_CONFIG_PREFIX ${config.home.homeDirectory}/.pi/npm/ \
          --prefix PATH : ${
            pkgs.lib.makeBinPath [
              pkgs.unstable.nodejs_latest
              pkgs.unstable.fd
            ]
          }
      '';
    })
  ];

  home.file = {
    ".pi/agent/skills/agent-browser/SKILL.md".source = ./skills/agent-browser/SKILL.md;

    ".agent-browser/config.json".text = builtins.toJSON {
      "$schema" = "https://agent-browser.dev/schema.json";
      cdp = "ws://portainer.home:4445/?stealth=1&--disable-web-security=true";
    };

    ".pi/agent/models.json".text = builtins.toJSON {
      providers = {
        ollama = {
          baseUrl = "http://wiggles.home:11434/v1";
          api = "openai-completions";
          apiKey = "ollama";
          models = [
            { id = "glm-5.1:cloud"; }
          ];
        };
      };
    };

    ".pi/agent/settings.json".text = builtins.toJSON {
      defaultProvider = "ollama";
      defaultModel = "glm-5.1:cloud";
    };
  };
}
{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.llm-agents.agent-browser

    (pkgs.symlinkJoin {
      name = "pi";
      nativeBuildInputs = [ pkgs.makeWrapper ];
      paths = [ pkgs.llm-agents.pi ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --set NPM_CONFIG_PREFIX ${config.home.homeDirectory}/.pi/npm/ \
          --prefix PATH : ${
            pkgs.lib.makeBinPath [
              pkgs.nodejs_latest
            ]
          }
      '';
    })
  ];

  home.file = {
    ".pi/agent/APPEND_SYSTEM.md".source = ./APPEND_SYSTEM.md;

    ".agent-browser/config.json".text = builtins.toJSON {
      "$schema" = "https://agent-browser.dev/schema.json";
      cdp = "ws://debian.home:3000/";
    };

    ".pi/agent/models.json".text = builtins.toJSON {
      providers = {
        llm = {
          baseUrl = "https://llm.kulak.us/v1";
          api = "openai-responses";
          apiKey = "sk-local-use-only";

          models = [
            {
              id = "gpt-5.5";
              reasoning = true;
              input = [
                "text"
                "image"
              ];
            }
          ];
        };
      };
    };

    ".pi/agent/settings.json".text = builtins.toJSON {
      defaultProvider = "llm";
      defaultModel = "gpt-5.5";
      defaultThinkingLevel = "high";
      theme = "catppuccin-mocha";

      prompts = [
        "${./prompts}"
      ];
      skills = [
        "${./skills}"
      ];
      themes = [
        "${./themes}"
      ];
    };
  };
}

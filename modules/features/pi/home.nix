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
          --set NPM_CONFIG_PREFIX ${config.home.homeDirectory}/.pi/npm/
      '';
    })
  ];

  home.file = {
    ".pi/agent/themes/catppuccin-mocha.json".source = ./themes/catpuccin-mocha.json;
    ".pi/agent/prompts/setup.md".source = ./prompts/setup.md;
    ".pi/agent/skills/agent-browser/SKILL.md".source = ./skills/agent-browser/SKILL.md;

    ".agent-browser/config.json".text = builtins.toJSON {
      "$schema" = "https://agent-browser.dev/schema.json";
      cdp = "ws://debian.home:3000/";
    };

    ".pi/agent/models.json".text = builtins.toJSON {
      providers = {
        llm = {
          baseUrl = "https://llm.kulak.us/v1";
          api = "openai-completions";
          apiKey = "sk-local-use-only";

          compat = {
            supportsDeveloperRole = false;
          };

          models = [
            {
              id = "gpt-main";
              reasoning = true;
              compat = {
                supportsReasoningEffort = true;
              };
            }
          ];
        };
      };
    };

    ".pi/agent/settings.json".text = builtins.toJSON {
      defaultProvider = "llm";
      defaultModel = "gpt-main";
      defaultThinkingLevel = "medium";
      theme = "catppuccin-mocha";
    };
  };
}

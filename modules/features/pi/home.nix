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
    ".pi/agent/APPEND_SYSTEM.md".text = ''
      You are on a Nix OS system. Utilities that require extensive setup and configuration, like python3 or nodejs, are not installed. You may use a nix shell to run any tool you like, set up however you need it. `apply_patch` is not available; use the `edit` tool instead.
    '';

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
              id = "gpt-main";
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
      defaultModel = "gpt-main";
      defaultThinkingLevel = "high";
      theme = "catppuccin-mocha";
    };
  };
}

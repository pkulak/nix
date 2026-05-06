{ pkgs, ... }:
{
  home.packages = [
    pkgs.llm-agents.agent-browser
    pkgs.llm-agents.pi
  ];

  home.file = {
    ".pi/agent/APPEND_SYSTEM.md".source = ./APPEND_SYSTEM.md;
    ".pi/agent/extensions/copy-code-block.ts".source = ./extensions/copy-code-block.ts;

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
              thinkingLevelMap = {
                off = "none";
                minimal = null;
                xhigh = "xhigh";
              };
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
      defaultThinkingLevel = "xhigh";
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

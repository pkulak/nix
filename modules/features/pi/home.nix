{ pkgs, ... }:

let
  rtkPiExtension = pkgs.runCommand "rtk-pi-extension.ts" { } ''
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    ${pkgs.llm-agents.rtk}/bin/rtk init -g --agent pi --hook-only --no-patch

    test -s "$HOME/.pi/agent/extensions/rtk.ts"
    cp "$HOME/.pi/agent/extensions/rtk.ts" "$out"
  '';
in
{
  home.packages = [
    pkgs.llm-agents.agent-browser
    pkgs.llm-agents.pi
    pkgs.llm-agents.rtk
    pkgs.pi-agent-browser-native
  ];

  home.file = {
    ".pi/agent/APPEND_SYSTEM.md".source = ./APPEND_SYSTEM.md;
    ".pi/agent/extensions/copy-code-block.ts".source = ./extensions/copy-code-block.ts;
    ".pi/agent/extensions/rtk.ts".source = rtkPiExtension;

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
              contextWindow = 272000;
              maxTokens = 128000;
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

      packages = [
        "${pkgs.pi-agent-browser-native}"
      ];

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

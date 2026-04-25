{ inputs }:
{
  config,
  pkgs,
  lib,
  ...
}:

# sudo machinectl shell opencrow@opencrow
# sudo machinectl shell opencrow@opencrow-group
# journalctl -M opencrow -f

let
  python = pkgs.python3.withPackages (ps: [ ps.beautifulsoup4 ]);

  mkPyScript =
    file:
    pkgs.writeShellScriptBin (builtins.replaceStrings [ ".py" ] [ "" ] file) ''
      exec ${python}/bin/python3 ${./bin}/${file} "$@"
    '';

  mkBashScript =
    file:
    pkgs.writeShellScriptBin (builtins.replaceStrings [ ".sh" ] [ "" ] file) ''
      exec ${pkgs.bash}/bin/bash ${./bin}/${file} "$@"
    '';

  watchmail = mkPyScript "watchmail.py";

  mkSharedBindMounts = prefix: {
    "${prefix}/.agent-browser" = {
      hostPath = "/home/phil/.agent-browser";
    };
    "${prefix}/.ssh" = {
      hostPath = "/home/phil/.ssh";
    };
    "${prefix}/.config" = {
      hostPath = "/home/phil/.config";
    };
    "${prefix}/.config/systemd" = {
      hostPath = "/var/empty";
    };
    "${prefix}/.local" = {
      hostPath = "/home/phil/.local";
    };
    "${prefix}/.local/share/systemd" = {
      hostPath = "/var/empty";
    };
  };

  mkDefaultServices =
    { pipePath, envFiles }:
    import ./services/personal.nix {
      inherit
        pkgs
        watchmail
        pipePath
        envFiles
        ;
    };

  mkGroupServices =
    { pipePath, envFiles }: import ./services/group.nix { inherit pkgs pipePath envFiles; };

  sharedInstanceConfig = {
    piPackage = pkgs.unstable.pi-coding-agent;

    environment = {
      OPENCROW_PI_IDLE_TIMEOUT = "6h";
      OPENCROW_MATRIX_HOMESERVER = "https://kulak.us";
      OPENCROW_PI_PROVIDER = "ollama";
      OPENCROW_PI_MODEL = "kimi-k2.5:cloud";
      TZ = "America/Los_Angeles";
    };

    piModels = {
      providers.ollama = {
        baseUrl = "http://debian.home:11434/v1";
        api = "openai-completions";
        apiKey = "ollama";

        compat = {
          supportsDeveloperRole = false;
          supportsReasoningEffort = false;
        };

        models = [
          {
            id = "kimi-k2.5:cloud";
            input = [
              "text"
              "image"
            ];
          }
        ];
      };
    };

    extensions = {
      reminders = true;
    };

    skills = {
      agent-browser = ../pi/skills/agent-browser;
      check-tennis = ./skills/check-tennis;
      download = ./skills/download;
      low-priority-email = ./skills/low-priority-email;
      morning-summary = ./skills/morning-summary;
      sports-scores = ./skills/sports-scores;
      transcribe = ./skills/transcribe;
      watch-tennis = ./skills/watch-tennis;
      wikipedia-lookup = ./skills/wikipedia-lookup;
    };

    environmentFiles = [
      config.age.secrets.opencrow-env.path
    ];

    extraPackages =
      with pkgs;
      [
        curl
        fd
        ffmpeg-over-ip
        git
        imagemagick
        jq
        khal
        neovim
        oath-toolkit
        openssh
        pandoc
        poppler
        ripgrep
        unstable.agent-browser
        unstable.yt-dlp
        unzip
        w3m
      ]
      ++ map mkPyScript [
        "getmail.py"
      ]
      ++ map mkBashScript [
        "events.sh"
        "ha.sh"
        "watchtennis.sh"
        "weather.sh"
      ];
  };
in
{
  imports = [ inputs.opencrow.nixosModules.default ];

  age.secrets.opencrow-env = {
    file = ../secrets/crypt/opencrow.env;
    mode = "400";
  };

  age.secrets.opencrow-group-env = {
    file = ../secrets/crypt/opencrow-group.env;
    mode = "400";
  };

  services.opencrow = sharedInstanceConfig // {
    enable = true;

    environment = sharedInstanceConfig.environment // {
      OPENCROW_MATRIX_USER_ID = "@wiggles:kulak.us";
      OPENCROW_SOUL_FILE = "${./souls/wiggles.txt}";
    };

    # skills that I only want in the default container
    skills = sharedInstanceConfig.skills // {
      check-email = ./skills/check-email;
      check-notes = ./skills/check-notes;
    };

    # mounts that I only want in the default container
    extraBindMounts = mkSharedBindMounts "/var/lib/opencrow" // {
      "/var/lib/opencrow/notes" = {
        hostPath = "/home/phil/notes";
      };
      "/var/lib/opencrow/nix" = {
        hostPath = "/home/phil/nix";
      };
    };

    instances.group = sharedInstanceConfig // {
      enable = true;

      environment = sharedInstanceConfig.environment // {
        OPENCROW_MATRIX_USER_ID = "@barnaby:kulak.us";
        OPENCROW_MATRIX_ROOM_ID = "!XNagljoCngXYEYCYCn:kulak.us";
        OPENCROW_SOUL_FILE = "${./souls/barnaby.txt}";
      };

      extraBindMounts = mkSharedBindMounts "/var/lib/opencrow-group";

      environmentFiles = sharedInstanceConfig.environmentFiles ++ [
        config.age.secrets.opencrow-group-env.path
      ];
    };
  };

  containers.opencrow.config.users.users.opencrow = {
    isSystemUser = lib.mkForce false;
    isNormalUser = lib.mkForce true;
    uid = lib.mkForce 1000;
    shell = "/run/current-system/sw/bin/bash";
  };
  containers.opencrow.config.systemd =
    let
      personal = mkDefaultServices {
        pipePath = "/var/lib/opencrow/sessions/trigger.pipe";
        envFiles = [ "/run/secrets/opencrow-envfile-0" ];
      };
    in
    {
      services = personal.services;
      timers = personal.timers;
    };

  containers.opencrow-group.config.users.users.opencrow = {
    isSystemUser = lib.mkForce false;
    isNormalUser = lib.mkForce true;
    uid = lib.mkForce 1000;
    shell = "/run/current-system/sw/bin/bash";
  };
  containers.opencrow-group.config.systemd =
    let
      group = mkGroupServices {
        pipePath = "/var/lib/opencrow-group/sessions/trigger.pipe";
        envFiles = [ "/run/secrets/opencrow-group-envfile-0" ];
      };
    in
    {
      services = group.services;
      timers = group.timers;
    };
}

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
    piPackage = pkgs.llm-agents.pi;

    environment = {
      OPENCROW_PI_IDLE_TIMEOUT = "6h";
      OPENCROW_MATRIX_HOMESERVER = "https://kulak.us";
      OPENCROW_PI_PROVIDER = "llm";
      OPENCROW_PI_MODEL = "gpt-main";
      TZ = "America/Los_Angeles";
    };

    piSettings = {
      defaultThinkingLevel = "low";
    };

    piModels = {
      providers.llm = {
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
            id = "kimi-k2.6:cloud";
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
      morning-summary = ./skills/morning-summary;
      noise-machine = ./skills/noise-machine;
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
        wget
        fd
        ripgrep
        git
        git-lfs
        gh
        delta

        file
        tree
        which
        less
        jq
        yq
        xan
        gron
        xmlstarlet
        libxml2
        htmlq
        sd
        fzf

        zip
        unzip
        p7zip
        zstd
        xz
        gzip
        bzip2
        gnutar

        imagemagick
        ffmpeg-over-ip
        poppler
        pandoc
        qpdf
        ghostscript
        exiftool
        mediainfo
        tesseract
        ocrmypdf

        sqlite
        neovim
        w3m

        shellcheck
        shfmt
        just
        gnumake
        cmake
        pkg-config
        gcc

        nodejs
        pnpm

        nix-output-monitor
        nixfmt-rfc-style
        nil
        statix
        deadnix

        dnsutils
        iputils
        iproute2
        netcat
        socat
        openssl

        khal
        oath-toolkit
        openssh
        llm-agents.agent-browser
        unstable.yt-dlp

        (python3.withPackages (
          ps: with ps; [
            requests
            beautifulsoup4
            lxml
            pyyaml
            pillow
            python-dateutil
            pandas
            pypdf
          ]
        ))
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

  environment.systemPackages = [ (mkBashScript "session.sh") ];

  services.opencrow = sharedInstanceConfig // {
    enable = true;

    environment = sharedInstanceConfig.environment // {
      OPENCROW_MATRIX_USER_ID = "@wiggles:kulak.us";
      OPENCROW_SOUL_FILE = "${./souls/wiggles.txt}";
      OPENCROW_HEARTBEAT_INTERVAL = "12h";
    };

    # skills that I only want in the default container
    skills = sharedInstanceConfig.skills // {
      check-email = ./skills/check-email;
      check-notes = ./skills/check-notes;
      low-priority-email = ./skills/low-priority-email;
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

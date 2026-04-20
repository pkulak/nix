{ inputs }:
{
  config,
  pkgs,
  lib,
  ...
}:

# sudo machinectl shell opencrow@opencrow
# sudo machinectl shell opencrow@opencrow-group
# journalctl -M opencrow -f & journalctl -M opencrow-group -f

let
  mkPyScript =
    file:
    pkgs.writeShellScriptBin (builtins.replaceStrings [ ".py" ] [ "" ] file) ''
      exec ${pkgs.python3}/bin/python3 ${./bin}/${file} "$@"
    '';

  mkBashScript =
    file:
    pkgs.writeShellScriptBin (builtins.replaceStrings [ ".sh" ] [ "" ] file) ''
      exec ${pkgs.bash}/bin/bash ${./bin}/${file} "$@"
    '';

  watchmail = mkPyScript "watchmail.py";

  mkDefaultServices =
    { pipePath, envFiles }: import ./services/personal.nix { inherit watchmail pipePath envFiles; };

  mkGroupServices =
    { pipePath, envFiles }: import ./services/group.nix { inherit pkgs pipePath envFiles; };

  sharedInstanceConfig = {
    piPackage = pkgs.unstable.pi-coding-agent;

    environment = {
      OPENCROW_MATRIX_HOMESERVER = "https://kulak.us";
      OPENCROW_MATRIX_USER_ID = "@wiggles:kulak.us";
      OPENCROW_PI_PROVIDER = "ollama";
      OPENCROW_PI_MODEL = "glm-5.1:cloud";
    };

    piModels = {
      providers.ollama = {
        baseUrl = "http://debian.home:11434/v1";
        api = "openai-completions";
        apiKey = "ollama";
        models = [ { id = "glm-5.1:cloud"; } ];
      };
    };

    extensions = {
      reminders = true;
    };

    skills = {
      agent-browser = ../pi/skills/agent-browser;
      check-email = ./skills/check-email;
      check-tennis = ./skills/check-tennis;
      morning-summary = ./skills/morning-summary;
      transcribe = ./skills/transcribe;
      watch-tennis = ./skills/watch-tennis;
    };

    extraBindMounts = {
      "/home/opencrow/.agent-browser" = {
        hostPath = "/home/phil/.agent-browser";
      };
      "/var/lib/opencrow/.config/khal" = {
        hostPath = "/home/phil/.config/khal";
      };
      "/var/lib/opencrow/.local/share/vdirsyncer/calendars" = {
        hostPath = "/home/phil/.local/share/vdirsyncer/calendars";
      };
      "/var/lib/opencrow/notes" = {
        hostPath = "/home/phil/notes";
      };
    };

    environmentFiles = [
      config.age.secrets.opencrow-env.path
    ];

    extraPackages =
      with pkgs;
      [
        curl
        jq
        ripgrep
        fd
        git
        khal
        w3m
        unstable.agent-browser
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
      OPENCROW_SOUL_FILE = "${./souls/wiggles.txt}";
    };

    instances.group = sharedInstanceConfig // {
      enable = true;

      environment = sharedInstanceConfig.environment // {
        OPENCROW_MATRIX_USER_ID = "@barnaby:kulak.us";
        OPENCROW_MATRIX_TRIGGER = "barnaby";
        OPENCROW_SOUL_FILE = "${./souls/barnaby.txt}";
      };

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

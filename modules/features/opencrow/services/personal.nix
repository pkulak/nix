# Extra systemd services for the default (personal) opencrow container.
{
  pkgs,
  watchmail,
  pipePath,
  envFiles,
}:

let
  checks = import ./checks.nix {
    inherit pkgs pipePath;

    checks = [
      {
        name = "check-lp-mail";
        calendar = "*-*-* 10:00:00";
        prompt = "Please run the low-priority-email skill.";
      }
      {
        name = "check-navi";
        calendar = "Mon..Fri *-*-* 12:00:00";
        prompt = "Remind me that Navi needs to be fed, if not already.";
      }
    ];
  };
in
{
  services = checks.services // {
    watchmail = {
      description = "Watch inbox and trigger opencrow on new mail";
      wantedBy = [ "multi-user.target" ];
      after = [ "opencrow.service" ];
      requires = [ "opencrow.service" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${watchmail}/bin/watchmail Please run the check-mail skill.";
        Restart = "on-failure";
        RestartSec = 10;
        EnvironmentFile = envFiles;
      };

      environment = {
        OPENCROW_TRIGGER_PIPE = pipePath;
      };
    };
  };

  timers = checks.timers;
}


# Extra systemd services for the default (personal) opencrow container.
{
  pkgs,
  watchmail,
  pipePath,
  envFiles,
}:

let
  triggerPipe = pkgs.writeShellScript "trigger-pipe" ''
    echo "$1" > ${pipePath}
  '';
in
{
  services = {
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

    check-lp-mail = {
      description = "Trigger low-priority mail check";
      after = [ "opencrow.service" ];
      requires = [ "opencrow.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''${triggerPipe} "Please run the low-priority-email skill."'';
      };
    };
  };

  timers = {
    check-lp-mail = {
      description = "Check low priority mail at 10am";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 10:00:00";
        Persistent = true;
      };
    };
  };
}

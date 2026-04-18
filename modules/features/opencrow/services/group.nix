# Extra systemd services for the group opencrow container.
{
  pkgs,
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
    morning-summary = {
      description = "Trigger morning summary";
      after = [ "opencrow.service" ];
      requires = [ "opencrow.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''${triggerPipe} "Please run the morning-summary skill."'';
      };
    };

    check-tennis = {
      description = "Trigger tennis check";
      after = [ "opencrow.service" ];
      requires = [ "opencrow.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''${triggerPipe} "Please run the check-tennis skill. If there are no open events, respond with NO_REPLY."'';
      };
    };
  };

  timers = {
    morning-summary = {
      description = "Morning summary at 6am";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 06:00:00";
        Persistent = true;
      };
    };

    check-tennis = {
      description = "Check tennis at 9:20am";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 09:20:00";
        Persistent = true;
      };
    };
  };
}

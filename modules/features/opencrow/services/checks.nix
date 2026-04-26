{
  pkgs,
  pipePath,
  checks,
}:

let
  triggerPipe = pkgs.writeShellScript "trigger-pipe" ''
    echo "$1" > ${pipePath}
  '';

  mkCheck =
    {
      name,
      calendar,
      prompt,
    }:
    {
      service = {
        description = "Trigger ${name}";
        after = [ "opencrow.service" ];
        requires = [ "opencrow.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''${triggerPipe} "${prompt}"'';
        };
      };
      timer = {
        description = "${name} at ${calendar}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = calendar;
          Persistent = true;
        };
      };
    };

  generated = builtins.listToAttrs (
    map (c: {
      name = c.name;
      value = mkCheck c;
    }) checks
  );
in
{
  services = builtins.mapAttrs (_: v: v.service) generated;
  timers = builtins.mapAttrs (_: v: v.timer) generated;
}
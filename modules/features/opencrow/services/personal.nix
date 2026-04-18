# Extra systemd services for the default (personal) opencrow container.
{
  watchmail,
  pipePath,
  envFiles,
}:

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
  };

  timers = { };
}

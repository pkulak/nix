# Extra systemd services for the group opencrow container.
{
  pkgs,
  pipePath,
  envFiles,
}:

import ./checks.nix {
  inherit pkgs pipePath;

  checks = [
    {
      name = "morning-summary";
      calendar = "*-*-* 06:00:00";
      prompt = "Run the morning-summary skill.";
    }
    {
      name = "check-tennis";
      calendar = "*-*-* 09:20:00";
      prompt = "Run the check-tennis skill. If there are no open events, respond with NO_REPLY.";
    }
    {
      name = "check-navi";
      calendar = "Sat,Sun *-*-* 12:00:00";
      prompt = "Remind everyone that Navi needs to be fed, if not already.";
    }
  ];
}


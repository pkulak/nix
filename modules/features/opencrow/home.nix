{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.vdirsyncer
    pkgs.khal
  ];

  home.activation.ensureBindMountDirs = config.lib.dag.entryBefore [ "checkLinkTargets" ] ''
    mkdir -p ~/.local/share/vdirsyncer/calendars
    mkdir -p ~/.local/share/vdirsyncer/status
    mkdir -p ~/notes
  '';

  xdg.configFile."vdirsyncer/config".text = ''
    [general]
    status_path = "~/.local/share/vdirsyncer/status/"

    [pair fastmail_calendar]
    a = "fastmail_calendar_local"
    b = "fastmail_calendar_remote"
    collections = ["from a", "from b"]
    conflict_resolution = "b wins"
    metadata = ["displayname", "color"]

    [storage fastmail_calendar_local]
    type = "filesystem"
    path = "~/.local/share/vdirsyncer/calendars/"
    fileext = ".ics"

    [storage fastmail_calendar_remote]
    type = "caldav"
    url = "https://caldav.fastmail.com/"
    username = "phil@kulak.us"
    password.fetch = ["command", "${pkgs.bash}/bin/sh", "-c", "grep OPENCROW_ICAL_PASSWORD ${config.age.secrets.opencrow-env.path} | cut -d= -f2-"]
  '';

  xdg.configFile."khal/config".text = ''
    [calendars]

    [[default]]
    path = ~/.local/share/vdirsyncer/calendars/*
    type = discover

    [locale]
    timeformat = %H:%M
    dateformat = %Y-%m-%d
    longdateformat = %Y-%m-%d %a
    datetimeformat = %Y-%m-%d %H:%M
    longdatetimeformat = %Y-%m-%d %H:%M
    default_timezone = America/Los_Angeles
    local_timezone = America/Los_Angeles

    [default]
    default_calendar = 1684fdb1-a37d-4e83-9564-2dd22d343019
    timedelta = 1d

    [view]
    agenda_event_format = {start-end-time-style} {title}
  '';

  systemd.user.services.vdirsyncer = {
    Unit = {
      Description = "Sync calendars with vdirsyncer";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    };
  };

  systemd.user.timers.vdirsyncer = {
    Unit.Description = "Sync calendars hourly";
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}

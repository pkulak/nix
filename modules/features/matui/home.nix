{ pkgs, ... }: {
  home.packages = [ pkgs.matui ];

  xdg.configFile."matui/config.toml".text = ''
    reactions = ["👍️", "✅", "😂", "🤣", "😘", "❤️", "🎉", "👎", "‼️", "❓️", "🙁", "🚀", "👆", "😱"]
    muted = ["!hMPITSQBLFEleSJmVm:kulak.us", "!zCIiPpUbrNESgmegGW:kulak.us"]
    max_events = 16384
  '';

  xdg.desktopEntries.matui = {
    name = "Matui";
    genericName = "Kulak Chat";
    comment = "Launch the Matui Matix client.";
    exec = "footclient --app-id=matui -e matui";
    icon = "im-matrix";
    terminal = false;
    categories = [ "Network" "InstantMessaging" "Chat" ];
    settings = {
      Keywords = "chat;messaging;matrix;im;";
      StartupNotify = "false";
    };
  };
}

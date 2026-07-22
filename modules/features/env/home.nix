{ pkgs, ... }:

let
  jdkRoot = "/run/current-system/sw/lib/jvm";
in
{
  home.sessionVariables = {
    TERMINAL = "footclient";
    EDITOR = "nvim";
    VISUAL = "nvim";
    JAVA_HOME = "${jdkRoot}/java-25-openjdk";
    JAVA_17_HOME = "${jdkRoot}/java-17-openjdk";
  };

  xdg.configFile."environment.sh" = {
    executable = true;

    text = # bash
      ''
        #!/usr/bin/env bash

        # jam some Vevo stuff in the env to make builds easier
        if test -f /home/phil/.m2/settings.xml; then
          export NEXUS_USER=deployment
          export NEXUS_PASSWORD=$(${pkgs.xq-xml}/bin/xq /home/phil/.m2/settings.xml -x "/settings/servers/*[1]/password")
        fi

        # and load secrets
        if test -f /home/phil/.config/environment-secrets.sh; then
          source /home/phil/.config/environment-secrets.sh
        fi
      '';
  };

  programs.bash.enable = true;

  programs.bash.profileExtra = ''
    source ~/.config/environment.sh
  '';
}

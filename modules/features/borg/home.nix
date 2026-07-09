{
  config,
  lib,
  pkgs,
  ...
}:

let
  base = "ssh://fm3067@fm3067.rsync.net/~/borg";

  repos = {
    debian = "${base}/debian";
    lilnas = "${base}/lilnas";
  };

  remotePath = "borg14";

  repoList = lib.concatStringsSep " " (builtins.attrNames repos);
  repoCases = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: repo: ''
      ${lib.escapeShellArg name})
        repo=${lib.escapeShellArg repo}
        ;;
    '') repos
  );

  borg-repo = pkgs.writeShellApplication {
    name = "borg-repo";
    runtimeInputs = with pkgs; [
      borgbackup
      openssh
    ];

    text = ''
      usage() {
        echo "usage: borg-repo <repo> <borg args...>" >&2
        echo "repos: ${repoList}" >&2
        exit 2
      }

      if [ "$#" -lt 1 ]; then
        usage
      fi

      repo_name="$1"
      shift

      case "$repo_name" in
      ${repoCases}
        *)
          echo "unknown borg repo: $repo_name" >&2
          usage
          ;;
      esac

      if [ -z "''${BORG_PASSPHRASE:-}" ]; then
        echo "BORG_PASSPHRASE is not set" >&2
        exit 1
      fi

      export BORG_REPO="$repo"

      exec borg --remote-path ${lib.escapeShellArg remotePath} "$@"
    '';
  };
in
{
  home.packages = [
    borg-repo
    pkgs.borgbackup
  ];
}

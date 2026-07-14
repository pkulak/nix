{
  config,
  lib,
  pkgs,
  ...
}:

let
  repos = {
    debian = "ssh://dzpop2ga@dzpop2ga.repo.borgbase.com/./repo";
    lilnas = "ssh://fm3067@fm3067.rsync.net/~/borg/lilnas";
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

  borg-mount = pkgs.writeShellApplication {
    name = "borg-mount";
    runtimeInputs = [
      borg-repo
      pkgs.coreutils
    ];

    text = ''
      if [ "$#" -ne 2 ]; then
        echo "usage: borg-mount <repo> <mountpoint>" >&2
        echo "repos: ${repoList}" >&2
        exit 2
      fi

      mountpoint="$2"
      mkdir -p "$mountpoint"

      exec borg-repo "$1" mount \
        -o "uid=$(id -u),gid=$(id -g),ignore_permissions" \
        :: "$mountpoint"
    '';
  };
in
{
  home.packages = [
    borg-mount
    borg-repo
    pkgs.borgbackup
  ];
}

{
  config,
  lib,
  pkgs,
  ...
}:

# Single `claude remote-control` server acting as an "agent host".
#
# Each session started from claude.ai/code or the Claude app gets an empty
# git repo under ${sessionsDir} (via the WorktreeCreate hook), fetches the
# repo named in the prompt into it and commits to a local branch. It only
# pushes and opens a draft PR when asked to.
# No per-repo configuration lives here.
#
# One-time manual setup (as the claude user) is required after the first
# switch: claude auth login, gh auth login, accepting the trust/consent
# prompts, and adding the signing key to GitHub. See docs/Claude Agents.md.

let
  cfg = config.services.claude-agents;

  home = "/var/lib/claude";
  inherit (cfg) agentsDir;
  sessionsDir = "${agentsDir}/sessions";
  archiveDir = "${agentsDir}/archive";

  # WorktreeCreate hook, used for the server's new sessions and for worktrees
  # those sessions create themselves (e.g. subagent isolation):
  #   - inside a git repo: behave like Claude Code's default git worktree
  #   - otherwise: hand out an empty git repo (no commits, no remote) under
  #     <cwd>/sessions
  # Only the final path may go to stdout; everything else goes to stderr.
  worktreeCreate = pkgs.writeShellScript "claude-worktree-create" ''
    set -euo pipefail
    export PATH=${
      lib.makeBinPath [
        pkgs.jq
        pkgs.git
        pkgs.coreutils
      ]
    }:$PATH

    in=$(cat)
    name=$(jq -er .name <<<"$in")
    cwd=$(jq -er .cwd <<<"$in")

    if top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); then
      dir="$top/.claude/worktrees/$name"
      git -C "$top" worktree add -b "worktree-$name" "$dir" >&2
    else
      dir="$cwd/sessions/$name"
      mkdir -p "$dir"
      # Make the folder a repo up front: the session's git state is checked
      # when it starts, before the agent fetches anything (see CLAUDE.md).
      git -C "$dir" init -q >&2
    fi

    echo "$dir"
  '';

  # Settings for the server and every session it starts. Passed with
  # `remote-control --settings`, so unlike managed settings they don't apply
  # to anyone else using Claude Code on this host.
  settings = {
    hooks.WorktreeCreate = [
      {
        hooks = [
          {
            type = "command";
            command = "${worktreeCreate}";
          }
        ];
      }
    ];
    permissions.allow = [
      "Bash(git:*)"
      "Bash(gh pr create:*)"
      "Bash(gh pr view:*)"
      # Ad-hoc tools (npm, go, cargo, ...) via Nix instead of global installs.
      # Note: these effectively allow any command, via --run / -c.
      "Bash(nix-shell:*)"
      "Bash(nix shell:*)"
      "Bash(nix develop:*)"
      "Bash(nix search:*)"
    ];
    # With --settings, sessions started from a claude.ai project only get
    # auto-compact if the settings turn it on.
    autoCompactEnabled = true;
  };

  settingsFile = pkgs.writeText "claude-agents-settings.json" (builtins.toJSON settings);

  # Remote Control pins the --settings file when it starts, and won't start a
  # session once the file is gone or different. A store path never changes,
  # but with restartIfChanged = false the server can outlive the generation
  # that references it, and a GC would then delete the file and the hook.
  # Keep the running server's copy alive. Runs as root (ExecStartPre=+).
  pinSettings = pkgs.writeShellScript "claude-agents-pin-settings" ''
    ${pkgs.coreutils}/bin/ln -sfn ${settingsFile} /nix/var/nix/gcroots/claude-agents-settings
  '';

  # Addresses sessions may not reach: the local network and everything else
  # that isn't the internet. This site's IPv6 prefixes are added at runtime
  # (see blockSiteIPv6); loopback depends on allowLoopback.
  localNetworks = [
    "0.0.0.0/8"
    "10.0.0.0/8"
    "100.64.0.0/10" # CGNAT range, also used by WireGuard and Tailscale
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "224.0.0.0/4" # multicast
    "240.0.0.0/4" # reserved, broadcast
    "fc00::/7" # unique local
    "fe80::/10" # link-local
    "ff00::/8" # multicast
  ];

  # On IPv6 the LAN uses public addresses, so unlike private IPv4 it can't be
  # blocked with a fixed range (and this repo is public). Take this site's
  # prefixes from the host's global IPv6 addresses and on-link routes, widen
  # each to the /48 an ISP delegates at most (which also covers VLANs the host
  # isn't on), and block them for everything in claude-agents.slice.
  # Runs as root, when the service starts and from a timer, so a late router
  # advertisement or a new prefix is picked up too. The list goes on the slice
  # rather than the service: set-property --runtime writes the unit's whole
  # IPAddressDeny list to a drop-in, which would keep the service's static
  # list from changing until the next reboot.
  blockSiteIPv6 = pkgs.writeShellApplication {
    name = "claude-agents-block-site-ipv6";
    runtimeInputs = [
      pkgs.iproute2
      pkgs.jq
      pkgs.coreutils
      config.systemd.package
    ];
    text = ''
      # Prints the /48 that contains an IPv6 address.
      slash48() {
        local head tail
        local -a h=() t=() g=()
        if [[ $1 == *::* ]]; then
          head=''${1%%::*} tail=''${1#*::}
        else
          head=$1 tail=
        fi
        if [[ -n $head ]]; then IFS=: read -ra h <<<"$head"; fi
        if [[ -n $tail ]]; then IFS=: read -ra t <<<"$tail"; fi
        g=("''${h[@]}")
        while ((''${#g[@]} + ''${#t[@]} < 8)); do g+=(0); done
        g+=("''${t[@]}")
        printf '%x:%x:%x::/48\n' "0x''${g[0]}" "0x''${g[1]}" "0x''${g[2]}"
      }

      addr_json=$(ip -json -6 addr show scope global)
      route_json=$(ip -json -6 route show)
      # Global unicast (2000::/3) addresses, and destinations of on-link routes
      addrs=$(jq -rn --argjson a "$addr_json" --argjson r "$route_json" '
        ($a[].addr_info[] | select(.scope == "global") | .local),
        ($r[] | select(.gateway == null) | .dst | sub("/.*"; ""))
        | select(test("^[23][0-9a-f]{0,3}:"))
      ')
      if [[ -z $addrs ]]; then
        echo "No global IPv6 addresses, nothing to block"
        exit 0
      fi

      prefixes=()
      while read -r addr; do prefixes+=("$(slash48 "$addr")"); done <<<"$addrs"
      mapfile -t prefixes < <(printf '%s\n' "''${prefixes[@]}" | sort -u)
      echo "Blocking this site's IPv6 prefixes for agent sessions: ''${prefixes[*]}"
      systemctl set-property --runtime claude-agents.slice "IPAddressDeny=''${prefixes[*]}"
    '';
  };

  # Removes session folders that nothing has touched for
  # sessionRetentionDays, each folder as a whole, after saving any work that
  # isn't on a remote. (Aging them with systemd-tmpfiles deleted old files one
  # by one, which could leave a still-used repo missing files and objects.)
  cleanupSessions = pkgs.writeShellApplication {
    name = "claude-agents-cleanup";
    runtimeInputs = [
      pkgs.git
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      days=${toString cfg.sessionRetentionDays}
      sessions=${sessionsDir}
      archive=${archiveDir}
      transcripts=${home}/.claude/projects
      shopt -s nullglob
      mkdir -p "$archive"

      # Author of the commits that hold saved uncommitted changes
      export GIT_AUTHOR_NAME=claude-agents-cleanup GIT_AUTHOR_EMAIL=claude-agents-cleanup@localhost
      export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL

      # Saves what deleting the repo at $1 would lose to $2.bundle: local
      # commits that aren't on a remote-tracking branch, and uncommitted
      # changes (untracked files too, ignored ones not). Writes nothing if
      # nothing would be lost.
      save_work() {
        local repo=$1 out=$2 tmp index tree head commit
        local -a parent=() revs=(--branches)

        # Snapshot the work tree using a copy of the index, so the repo is
        # left as it is.
        tmp=$(mktemp -d)
        index=$(git -C "$repo" rev-parse --path-format=absolute --git-path index)
        if [[ -f $index ]]; then cp "$index" "$tmp/index"; fi
        GIT_INDEX_FILE=$tmp/index git -C "$repo" add --all
        tree=$(GIT_INDEX_FILE=$tmp/index git -C "$repo" write-tree)
        rm -rf "$tmp"

        if head=$(git -C "$repo" rev-parse --quiet --verify 'HEAD^{commit}'); then
          parent=(-p "$head")
          if [[ $tree == "$(git -C "$repo" rev-parse 'HEAD^{tree}')" ]]; then tree=; fi
          # A detached HEAD's commits may not be on any branch
          if ! git -C "$repo" symbolic-ref --quiet HEAD >/dev/null; then revs+=(HEAD); fi
        elif [[ $tree == "$(git -C "$repo" hash-object -t tree /dev/null)" ]]; then
          tree=
        fi
        if [[ -n $tree ]]; then
          commit=$(git -C "$repo" commit-tree --no-gpg-sign "''${parent[@]}" -m "Uncommitted changes" "$tree")
          git -C "$repo" update-ref refs/archive/uncommitted "$commit"
          revs+=(refs/archive/uncommitted)
        fi

        if [[ $(git -C "$repo" rev-list --count "''${revs[@]}" --not --remotes) == 0 ]]; then
          return 0
        fi
        git -C "$repo" bundle create --quiet "$out.bundle" "''${revs[@]}" --not --remotes
        printf 'origin: %s\nfolder: %s\n' \
          "$(git -C "$repo" remote get-url origin 2>/dev/null || echo none)" "$repo" >"$out.txt"
        echo "Saved unpushed work in $repo to $out.bundle"
      }

      # Session folders that a running session is using
      declare -A busy=()
      for link in /proc/[0-9]*/cwd; do
        cwd=$(readlink "$link" 2>/dev/null) || continue
        if [[ $cwd == "$sessions"/* ]]; then
          cwd=''${cwd#"$sessions"/}
          busy[''${cwd%%/*}]=1
        fi
      done

      status=0
      for dir in "$sessions"/*/; do
        dir=''${dir%/}
        if [[ -n ''${busy[''${dir##*/}]:-} ]]; then continue; fi

        # Still active: something in the folder, or the session's transcript,
        # changed in the last $days days
        transcript=$transcripts/''${dir//[^a-zA-Z0-9]/-}
        if [[ -n $(find "$dir" "$transcript" -mtime "-$days" -print -quit 2>/dev/null) ]]; then
          continue
        fi

        # Save the work in each repo in the folder (normally just the folder)
        saved=1
        while IFS= read -r -d "" gitpath; do
          repo=''${gitpath%/.git}
          rel=''${repo#"$sessions"/}
          set +e
          (
            set -e
            save_work "$repo" "$archive/''${rel//\//%}"
          ) </dev/null
          rc=$?
          set -e
          if ((rc != 0)); then saved=0; fi
        done < <(find "$dir" -name .git -prune -print0)

        if ((!saved)); then
          echo "Keeping $dir: couldn't save its unpushed work" >&2
          status=1
          continue
        fi
        # Nix store copies and the like can be read-only
        chmod -R u+w "$dir"
        rm -rf --one-file-system "$dir"
        echo "Removed $dir, inactive for $days days"
      done
      exit "$status"
    '';
  };

  agentsClaudeMd = pkgs.writeText "claude-agents-CLAUDE.md" (
    ''
      # Agent host instructions

      You are running as a remote agent on a home server. Follow this workflow:

      0. If your working directory is `${agentsDir}` itself (not a folder
         under `sessions/`), first create `${sessionsDir}/<short-slug>`,
         run `git init -q` in it, and do all work there.
      1. You start in an empty git repository (no commits, no remote). Work
         out which GitHub repository the task is about${
           lib.optionalString (cfg.defaultOwner != null) " (default owner: `${cfg.defaultOwner}`)"
         }. If it's ambiguous, ask before doing anything else.
      2. Don't clone: the folder already has a `.git`, so `git clone` and
         `gh repo clone` would fail. Fetch the repository into it instead,
         running these one at a time:

         ```bash
         git init -q    # only if `git status` says this isn't a git repository
         git remote add origin https://github.com/<owner>/<repo>.git
         git fetch origin
         git remote set-head origin --auto
         git symbolic-ref --short refs/remotes/origin/HEAD   # prints origin/<default>
         git checkout -b <default> --track origin/<default>
         ```

         Then read that repository's `CLAUDE.md` (if it has one) and follow it.
      3. Create a branch with `git checkout -b claude/<short-slug-of-the-task>`.
         Never commit to the default branch.
      4. When you're done, commit to your local branch and reply with a short
         summary of the changes.
      5. Don't push and don't open a pull request until the user explicitly
         asks you to, either in the task or later in the conversation.
         Finishing the work is not a request to push. If they haven't asked,
         end your reply by asking whether they'd like you to push the branch
         and open a draft PR.
      6. When they ask: push the branch with `git push -u origin <branch>`,
         open a draft PR with `gh pr create --draft`, and reply with the PR
         URL.

      ## Tools

      This host runs NixOS and very little is installed globally, and you can't
      install anything system-wide. When you need a tool, package manager or
      runtime (node/npm, go, python/pip, cargo, make, jq, ...), run it through
      Nix instead:

      - If the repo has a dev shell (`flake.nix` with `devShells`, or
        `shell.nix`/`default.nix`), use it so you get the project's versions:
        `nix develop -c npm ci` or `nix-shell --run 'npm ci'`.
      - Otherwise use a throwaway shell with the packages you need:
        `nix-shell -p nodejs --run 'npm ci'`,
        `nix shell nixpkgs#go -c go mod tidy`.
      - Find package names with `nix search nixpkgs <name>`.

      Don't try `apt`, `sudo`, `npm install -g`, `pip install --user` or
      `curl | sh` installers.
    ''
    + lib.optionalString (cfg.gitName != null) ''

      Git commit identity is set via the environment. Don't change it (no
      `git config user.*`, no `-c user.*`).
    ''
    + lib.optionalString cfg.signCommits ''

      Commits are signed automatically. Don't disable signing (no
      `-c commit.gpgsign=false`, `--no-gpg-sign` or similar). If a commit fails
      to sign, stop and report the error.
    ''
    + ''

      ## Network

      You can reach the internet but not the local network: private and
      link-local addresses, and this site's own IPv6 addresses, are blocked${
        if cfg.allowLoopback then
          ".\n`localhost` works, for example for a test server or database you start."
        else
          ",\nand so is `localhost`."
      }
    ''
  );

  # Dedicated SSH key used only for signing commits. Generated on first start
  # (never in the Nix store); add the .pub to GitHub as a *signing* key.
  signingKey = "${home}/.ssh/signing_key";

  ensureSigningKey = pkgs.writeShellScript "claude-agents-ensure-signing-key" ''
    set -euo pipefail
    if [ ! -e ${signingKey} ]; then
      ${pkgs.coreutils}/bin/install -d -m 700 ${home}/.ssh
      ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" \
        -C "claude-agents@${config.networking.hostName} commit signing" \
        -f ${signingKey}
      echo "Generated ${signingKey}.pub; add it to GitHub as a signing key" >&2
    fi
  '';

  # Turn { "key" = [ v1 v2 ]; } into GIT_CONFIG_COUNT/KEY_n/VALUE_n env vars.
  # Git applies these on top of all config files, in order.
  gitConfigEnv =
    attrs:
    let
      pairs = lib.concatLists (
        lib.mapAttrsToList (key: values: map (value: { inherit key value; }) values) attrs
      );
    in
    {
      GIT_CONFIG_COUNT = toString (lib.length pairs);
    }
    // lib.listToAttrs (
      lib.concatLists (
        lib.imap0 (i: p: [
          (lib.nameValuePair "GIT_CONFIG_KEY_${toString i}" p.key)
          (lib.nameValuePair "GIT_CONFIG_VALUE_${toString i}" p.value)
        ]) pairs
      )
    );

  servicePath = [
    cfg.package
    pkgs.git
    pkgs.gh
    pkgs.openssh
    pkgs.jq
    pkgs.coreutils
    pkgs.bash
    pkgs.nix
  ];

  # Sandboxing for the agent host and its cleanup job. Sessions run arbitrary
  # commands, so this takes away what they don't need, but nothing that
  # common tools do. Left out on purpose:
  #   - MemoryDenyWriteExecute: breaks JITs (node, bun, java, ...)
  #   - RestrictNamespaces, SystemCallFilter: break Chromium's and
  #     bubblewrap's sandboxes, debuggers and the like
  #   - ProcSubset = "pid": hides /proc/cpuinfo and /proc/meminfo, which
  #     build tools read to size their worker pools
  #   - PrivateUsers: other users' files would show as owned by nobody
  sandbox = {
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;
    PrivateIPC = true;
    ProtectSystem = "strict";
    ReadWritePaths = [
      home
      agentsDir
    ];
    ProtectHome = true;
    ProtectProc = "invisible";
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    RestrictSUIDSGID = true;
    RestrictRealtime = true;
    LockPersonality = true;
    SystemCallArchitectures = "native";
    CapabilityBoundingSet = "";
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
      "AF_NETLINK"
    ];
  };
in
{
  options.services.claude-agents = {
    enable = lib.mkEnableOption "a Claude Code Remote Control agent host";

    package = lib.mkPackageOption pkgs "claude-code" { };

    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      defaultText = lib.literalExpression "config.networking.hostName";
      description = "Name shown for this host in claude.ai/code and the Claude app.";
    };

    agentsDir = lib.mkOption {
      type = lib.types.pathWith {
        inStore = false;
        absolute = true;
      };
      default = "${home}/agents";
      example = "/srv/claude/agents";
      description = ''
        Working directory of the agent host. It holds the agents' CLAUDE.md,
        a `sessions/` folder with one scratch git repo per session, and an
        `archive/` folder for work saved by the cleanup. Missing parent
        directories are created owned by root. The claude user must have
        trusted this folder once interactively (see docs/Claude Agents.md).
      '';
    };

    capacity = lib.mkOption {
      type = lib.types.ints.positive;
      default = 6;
      description = "Maximum number of concurrent sessions.";
    };

    permissionMode = lib.mkOption {
      type = lib.types.enum [
        "acceptEdits"
        "auto"
        "bypassPermissions"
        "default"
        "dontAsk"
        "plan"
      ];
      default = "acceptEdits";
      description = "Permission mode for spawned sessions.";
    };

    defaultOwner = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "octocat";
      description = "GitHub owner assumed when a prompt names a repo without one.";
    };

    gitName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Author/committer name for commits made by agent sessions. If null,
        git falls back to the claude user's own git config.
      '';
    };

    gitEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Author/committer email for commits made by agent sessions. If null,
        git falls back to the claude user's own git config.
      '';
    };

    signCommits = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Sign commits and tags with a dedicated SSH key generated at
        ${signingKey}. Add its .pub to GitHub as a signing key so commits
        show as Verified.
      '';
    };

    sessionRetentionDays = lib.mkOption {
      type = lib.types.ints.positive;
      default = 14;
      description = ''
        Remove a session's folder under `agentsDir`/sessions once neither the
        folder nor the session's transcript has changed for this many days.
        Unpushed commits and uncommitted changes are saved as a git bundle in
        `agentsDir`/archive first, and bundles are kept for 90 days.
      '';
    };

    allowLoopback = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Let sessions connect to localhost, e.g. to a test server or database
        they started. This also reaches this host's own services that listen
        on all interfaces. The rest of the local network is blocked either way.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.gitName == null) == (cfg.gitEmail == null);
        message = "services.claude-agents: set both gitName and gitEmail, or neither.";
      }
      {
        assertion = config.services.resolved.enable;
        message = ''
          services.claude-agents: sessions can't reach the local network, so DNS
          has to go through systemd-resolved on 127.0.0.53. Enable services.resolved.
        '';
      }
    ];

    users.users.claude = {
      isSystemUser = true;
      group = "claude";
      description = "Claude Code agent host";
      inherit home;
      createHome = true;
      shell = pkgs.bashInteractive;
      # So the manual `sudo -u claude -H bash -lc ...` setup has these on PATH
      packages = servicePath;
    };
    users.groups.claude = { };

    systemd.tmpfiles.rules = [
      "d ${agentsDir} 0750 claude claude -"
      # No age: claude-agents-cleanup removes inactive sessions as a whole
      "d ${sessionsDir} 0750 claude claude -"
      "d ${archiveDir} 0750 claude claude 90d"
      "L+ ${agentsDir}/CLAUDE.md - - - - ${agentsClaudeMd}"
    ];

    # Holds the service, so this site's IPv6 prefixes can be blocked at
    # runtime (see blockSiteIPv6)
    systemd.slices.claude-agents.description = "Claude Code agent host";

    systemd.services.claude-agents = {
      description = "Claude Code Remote Control agent host";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = [ agentsDir ];

      # Don't kill running agent sessions on nixos-rebuild switch
      restartIfChanged = false;

      path = servicePath;

      # Remote Control refuses to start with ANTHROPIC_API_KEY,
      # CLAUDE_CODE_OAUTH_TOKEN, DISABLE_GROWTHBOOK or
      # CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC set, so don't add them here.
      environment = {
        HOME = home;
        DISABLE_AUTOUPDATER = "1";
        # Services don't get the login NIX_PATH; without it `nix-shell -p`
        # can't find <nixpkgs>.
        NIX_PATH = lib.concatStringsSep ":" config.nix.nixPath;
      }
      # Commit identity. Env vars take precedence over `git -c user.*` and
      # any git config, so sessions can't commit under another identity.
      // lib.optionalAttrs (cfg.gitName != null) {
        GIT_AUTHOR_NAME = cfg.gitName;
        GIT_AUTHOR_EMAIL = cfg.gitEmail;
        GIT_COMMITTER_NAME = cfg.gitName;
        GIT_COMMITTER_EMAIL = cfg.gitEmail;
      }
      // gitConfigEnv (
        {
          # Auth is a gh token over HTTPS, not SSH: rewrite SSH GitHub URLs
          # (from gh's git_protocol, submodules, etc.) so clone/push don't hit
          # SSH host key verification.
          "url.https://github.com/.insteadOf" = [
            "git@github.com:"
            "ssh://git@github.com/"
          ];
          # `gh auth setup-git` writes an absolute /nix/store path to gh, which
          # breaks once that gh is garbage-collected. Reset the helper list
          # (empty value) and use gh from PATH instead.
          "credential.https://github.com.helper" = [
            ""
            "!gh auth git-credential"
          ];
        }
        // lib.optionalAttrs cfg.signCommits {
          "gpg.format" = [ "ssh" ];
          "user.signingKey" = [ signingKey ];
          "commit.gpgSign" = [ "true" ];
          "tag.gpgSign" = [ "true" ];
        }
      );

      serviceConfig = sandbox // {
        User = "claude";
        Group = "claude";
        Slice = "claude-agents.slice";
        WorkingDirectory = agentsDir;
        ExecStartPre = [
          "+${pinSettings}"
          "+${lib.getExe blockSiteIPv6}"
        ]
        ++ lib.optional cfg.signCommits ensureSigningKey;
        ExecStart = lib.escapeShellArgs [
          (lib.getExe cfg.package)
          "remote-control"
          # First, as remote-control asks
          "--settings"
          settingsFile
          "--name"
          cfg.name
          "--spawn"
          "worktree"
          "--capacity"
          (toString cfg.capacity)
          "--permission-mode"
          cfg.permissionMode
          # Not using --no-create-session-in-dir: with 2.1.223 the server then
          # fails to register (409 "This folder is already served") while the
          # previous server's sessions are still unarchived. The pre-created
          # session in ${agentsDir} is handled by CLAUDE.md instead.
        ];
        Restart = "always";
        RestartSec = 10;

        # Internet only. Also see localNetworks and blockSiteIPv6.
        IPAddressDeny = localNetworks ++ lib.optional (!cfg.allowLoopback) "localhost";
        # systemd-resolved's stub resolvers
        IPAddressAllow = lib.optionals (!cfg.allowLoopback) [
          "127.0.0.53"
          "127.0.0.54"
        ];
      };
    };

    systemd.services.claude-agents-block-site-ipv6 = {
      description = "Block this site's IPv6 prefixes for Claude agent sessions";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe blockSiteIPv6;
      };
    };
    systemd.timers.claude-agents-block-site-ipv6 = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "15min";
      };
    };

    systemd.services.claude-agents-cleanup = {
      description = "Remove inactive Claude agent session folders";
      unitConfig.RequiresMountsFor = [ agentsDir ];
      serviceConfig = sandbox // {
        Type = "oneshot";
        User = "claude";
        Group = "claude";
        ExecStart = lib.getExe cleanupSessions;
        ReadWritePaths = [ agentsDir ];
        PrivateNetwork = true;
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
    systemd.timers.claude-agents-cleanup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };

  # Setup procedure, troubleshooting and limitations: docs/Claude Agents.md
}

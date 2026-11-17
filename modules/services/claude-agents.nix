{
  config,
  lib,
  pkgs,
  ...
}:

# Single `claude remote-control` server acting as an "agent host".
#
# Each session started from claude.ai/code or the Claude app gets an empty
# scratch folder under ${agentsDir}/sessions (via the WorktreeCreate hook),
# clones the repo named in the prompt, works on a branch and pushes it. It only
# opens a draft PR when asked to.
# No per-repo configuration lives here.
#
# One-time manual setup (as the claude user) is required after the first
# switch: claude auth login, gh auth login, accepting the trust/consent
# prompts, and adding the signing key to GitHub. See docs/Claude Agents.md.

let
  cfg = config.services.claude-agents;

  home = "/var/lib/claude";
  agentsDir = "${home}/agents";

  # WorktreeCreate hook. Lives in managed settings, so it applies to every
  # user on this host:
  #   - inside a git repo: behave like Claude Code's default git worktree
  #   - otherwise: hand out an empty scratch folder under <cwd>/sessions
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
    fi

    echo "$dir"
  '';

  managedSettings = {
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
      "Bash(gh repo clone:*)"
      "Bash(gh pr create:*)"
      "Bash(gh pr view:*)"
      # Ad-hoc tools (npm, go, cargo, ...) via Nix instead of global installs.
      # Note: these effectively allow any command, via --run / -c.
      "Bash(nix-shell:*)"
      "Bash(nix shell:*)"
      "Bash(nix develop:*)"
      "Bash(nix search:*)"
    ];
  };

  agentsClaudeMd = pkgs.writeText "claude-agents-CLAUDE.md" (
    ''
      # Agent host instructions

      You are running as a remote agent on a home server. Follow this workflow:

      0. If your working directory is `${agentsDir}` itself (not a folder
         under `sessions/`), first create `${agentsDir}/sessions/<short-slug>`
         and do all work there.
      1. You start in an empty scratch folder. Work out which GitHub repository
         the task is about${
           lib.optionalString (cfg.defaultOwner != null) " (default owner: `${cfg.defaultOwner}`)"
         }. If it's ambiguous, ask before doing anything else.
      2. Clone it into the current folder with
         `gh repo clone <owner>/<repo> .`, then read that repository's
         `CLAUDE.md` (if it has one) and follow it.
      3. Create a branch named `claude/<short-slug-of-the-task>`. Never commit
         to the default branch.
      4. When you're done: commit, push the branch, and reply with a short
         summary and the branch name.
      5. Don't open a pull request unless the user has explicitly asked for
         one, either in the task or later in the conversation. Finishing the
         work is not a request for a PR. If they haven't asked, end your reply
         by asking whether they'd like you to open a draft PR. When they ask,
         open it with `gh pr create --draft` and reply with the PR URL.

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
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.gitName == null) == (cfg.gitEmail == null);
        message = "services.claude-agents: set both gitName and gitEmail, or neither.";
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

    environment.etc."claude-code/managed-settings.json".text = builtins.toJSON managedSettings;

    systemd.tmpfiles.rules = [
      "d ${agentsDir} 0750 claude claude -"
      # Scratch folders are never removed by a WorktreeRemove hook; age them out instead
      "d ${agentsDir}/sessions 0750 claude claude 14d"
      "L+ ${agentsDir}/CLAUDE.md - - - - ${agentsClaudeMd}"
    ];

    systemd.services.claude-agents = {
      description = "Claude Code Remote Control agent host";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

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

      serviceConfig = {
        User = "claude";
        Group = "claude";
        WorkingDirectory = agentsDir;
        ExecStartPre = lib.mkIf cfg.signCommits ensureSigningKey;
        ExecStart = lib.escapeShellArgs [
          (lib.getExe cfg.package)
          "remote-control"
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

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ home ];
      };
    };
  };

  # Setup procedure, troubleshooting and limitations: docs/Claude Agents.md
}

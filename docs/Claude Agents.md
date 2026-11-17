# Claude Agents (agent host on `server`)

`server` runs a single `claude remote-control` server as a systemd service
(`claude-agents`). From the Claude mobile app or [claude.ai/code](https://claude.ai/code)
you can start a session on the **homelab** environment that behaves like a cloud agent:

1. The session starts in an empty scratch folder.
2. It clones whichever GitHub repo you name in your prompt (default owner `chrisnharvey`).
3. It works on a `claude/<slug>` branch, commits (signed, as you), pushes and opens a **draft PR**.

There is no per-repo configuration. Adding a new repo needs no changes here, only access for the
GitHub token (see [GitHub token](#github-token)).

The module is [`modules/services/claude-agents.nix`](../modules/services/claude-agents.nix). It has
generic defaults; the `server`-specific values are set in
[`systems/server/configuration.nix`](../systems/server/configuration.nix):

```nix
services.claude-agents = {
  enable = true;
  package = pkgsUnstable.claude-code;   # claude-code from nixpkgs-unstable
  name = "homelab";
  defaultOwner = "chrisnharvey";
  gitName = config.home-manager.users.chris.programs.git.settings.user.name;
  gitEmail = config.home-manager.users.chris.programs.git.settings.user.email;
};
```

## How it works

```
claude.ai/code / Claude app
        │  (outbound HTTPS only, no inbound ports)
        ▼
claude-agents.service  ── user `claude`, cwd /var/lib/claude/agents (not a git repo)
  claude remote-control --name homelab --spawn worktree --capacity 6 --permission-mode acceptEdits
        │
        │ new session → WorktreeCreate hook (managed settings)
        ▼
/var/lib/claude/agents/sessions/<name>/   ← empty scratch folder per session
        │  reads /var/lib/claude/agents/CLAUDE.md (picked up from the parent folder)
        ▼
gh repo clone owner/repo .  →  branch claude/<slug>  →  commit  →  push  →  gh pr create --draft
```

| Piece | Where | Notes |
|---|---|---|
| Service | `systemd.services.claude-agents` | `restartIfChanged = false`, so a rebuild doesn't kill running agents. `Restart=always`. Hardened with `ProtectSystem=strict` etc.; only `/var/lib/claude` is writable. |
| User | `claude`, home `/var/lib/claude` | System user. Holds the Claude login, gh token and signing key. |
| Managed settings | `/etc/claude-code/managed-settings.json` | `WorktreeCreate` hook + `permissions.allow` for `git`, `gh repo clone`, `gh pr create`, `gh pr view`, `nix-shell`, `nix shell`, `nix develop`, `nix search`. Applies to **every user** on `server`. |
| Agent instructions | `/var/lib/claude/agents/CLAUDE.md` | Symlink into the Nix store (tmpfiles `L+`). The workflow sessions follow. |
| Scratch folders | `/var/lib/claude/agents/sessions/` | Removed by `systemd-tmpfiles` after 14 days. There is deliberately no `WorktreeRemove` hook. |
| Signing key | `/var/lib/claude/.ssh/signing_key` | ed25519, generated on first service start (`ExecStartPre`), never in the Nix store. |

### The WorktreeCreate hook

`--spawn worktree` normally needs a git repo. Instead the hook decides per call:

- **`cwd` is inside a git repo:** acts like Claude Code's default
  (`git worktree add -b worktree-<name> <top>/.claude/worktrees/<name>`). This keeps
  `claude --worktree`, subagent isolation etc. working for other users on `server`.
- **Otherwise:** `mkdir -p <cwd>/sessions/<name>` and returns that. This is the agent-host case.

It prints only the path on stdout; everything else goes to stderr.

### Tools via Nix

Almost nothing is installed for the `claude` user, and sessions can't install anything system-wide.
`CLAUDE.md` tells sessions to run package managers and other tools through Nix, preferring the
repo's own dev shell:

```bash
nix develop -c npm ci                       # repo has a flake dev shell
nix-shell --run 'npm ci'                    # repo has shell.nix / default.nix
nix-shell -p nodejs --run 'npm ci'          # ad hoc
nix shell nixpkgs#go -c go mod tidy         # ad hoc (flakes)
nix search nixpkgs <name>                   # find package names
```

`nix-shell`, `nix shell`, `nix develop` and `nix search` are pre-approved in the managed settings.
Because `--run` / `-c` take any command, this effectively lets sessions run any command without
asking, and `nix develop` also runs the repo's `shellHook`. The service sets `NIX_PATH` from
`nix.nixPath` (services don't get the login one), so `<nixpkgs>` resolves to the system's nixpkgs.
Unfree packages aren't allowed in these shells.

### Git setup (all via the service environment)

Spawned sessions inherit these from the service, so nothing depends on `~/.gitconfig`:

- **Identity:** `GIT_AUTHOR_*` / `GIT_COMMITTER_*` from `services.claude-agents.gitName` /
  `gitEmail`. On `server` these come from the home-manager git config (`homes/chris/common.nix`).
  If unset, git uses the `claude` user's own git config.
- **HTTPS only:** `git@github.com:` and `ssh://git@github.com/` are rewritten to
  `https://github.com/`, so a gh `git_protocol` of `ssh` or SSH submodule URLs don't hit
  "Host key verification failed".
- **Credentials:** `credential.https://github.com.helper = !gh auth git-credential`, using `gh`
  from `PATH`. `gh auth setup-git` writes an absolute `/nix/store/...` path, which breaks after GC.
- **Signing:** `gpg.format=ssh`, `user.signingKey=/var/lib/claude/.ssh/signing_key`,
  `commit.gpgSign=true`, `tag.gpgSign=true`. Disable with `services.claude-agents.signCommits = false`.

These are set with `GIT_CONFIG_COUNT` / `GIT_CONFIG_KEY_n` / `GIT_CONFIG_VALUE_n`, which override
config files but **not** `git -c ...` on the command line. `CLAUDE.md` tells sessions not to override
identity or signing.

## Options

| Option | Default | `server` | |
|---|---|---|---|
| `enable` | `false` | `true` | |
| `package` | `pkgs.claude-code` | unstable `claude-code` | See [Updating Claude Code](#updating-claude-code). |
| `name` | `networking.hostName` | `"homelab"` | Name shown in claude.ai/code. |
| `capacity` | `6` | | Max concurrent sessions, **including** the pre-created one (see [Known limitations](#known-limitations)). |
| `permissionMode` | `"acceptEdits"` | | Permission mode for spawned sessions. |
| `defaultOwner` | `null` | `"chrisnharvey"` | GitHub owner assumed when the prompt doesn't name one. |
| `gitName` / `gitEmail` | `null` | home-manager git identity | Commit author/committer. Set both or neither. |
| `signCommits` | `true` | | Sign commits and tags with the dedicated SSH key. |

## Setup procedure

### 1. Deploy

```bash
sudo nixos-rebuild --flake ~/nix-config switch
```

Until step 2 is done the service fails and restarts every 10s with
`You must be logged in to use Remote Control`. That's expected. Stop it while you do the setup so it
doesn't compete with the interactive run:

```bash
sudo systemctl stop claude-agents
```

### 2. One-time setup as the `claude` user

```bash
sudo -u claude -H bash -lc '
  claude auth login                     # choose the claude.ai (subscription) option
  gh auth login                         # GitHub.com → HTTPS → paste token (see below)
  gh config set git_protocol https
  cd ~/agents && claude                 # accept "trust this folder", then quit
  claude remote-control                 # answer y to "Enable Remote Control?", then Ctrl-C
'
```

Run these from a directory the `claude` user can read (for example not inside `/home/chris`),
otherwise git prints `failed to stat` errors.

- `claude auth login` **must** be a claude.ai subscription login. API keys, `ANTHROPIC_AUTH_TOKEN`,
  `apiKeyHelper` and `claude setup-token` / `CLAUDE_CODE_OAUTH_TOKEN` tokens can't establish Remote
  Control sessions.
- The trust and consent prompts must be answered once interactively. Without a TTY the service
  can't answer them and exits (`Workspace not trusted`).
- `gh auth setup-git` isn't needed: the credential helper is set by the service.

#### GitHub token

Use a **fine-grained personal access token** limited to your repos, with:

- **Contents:** read and write (clone, push)
- **Pull requests:** read and write (`gh pr create`, `gh pr view`)
- **Metadata:** read (always required)

New repos are only reachable if the token covers them ("All repositories" for your account, or add
the repo to the token).

### 3. Start the service

```bash
sudo systemctl start claude-agents
```

On first start `ExecStartPre` generates the signing key.

### 4. Add the signing key to GitHub

```bash
sudo cat /var/lib/claude/.ssh/signing_key.pub
```

GitHub → **Settings → SSH and GPG keys → New SSH key**, **Key type: Signing Key**, paste. This has
to be done in the browser (a fine-grained token can't add signing keys). Agent commits then show
**Verified**, provided the commit email is a verified email on your GitHub account.

### 5. Verify

```bash
systemctl status claude-agents
journalctl -u claude-agents -f
```

`homelab` should appear in the Code tab of the app / claude.ai/code. Start a **new** session with
something like:

> in nix-config, add a comment to README and open a draft PR

Then check:

```bash
sudo -u claude bash -c 'cd /var/lib/claude/agents/sessions && for d in */; do
  echo "$d: $(git -C "$d" branch --show-current 2>/dev/null) $(git -C "$d" log -1 --format="%an <%ae> sig=%G?" 2>/dev/null)"
done'
```

Expect a `bridge-<session id>` folder on a `claude/...` branch, authored as you, and a draft PR
whose commit shows Verified.

## Operations

- **Rebuilds don't restart the service** (`restartIfChanged = false`). To apply changes to the unit,
  `sudo systemctl restart claude-agents`. This ends running sessions.
- **Logs:** `journalctl -u claude-agents`. The server redraws its status screen into stdout, so
  expect ~80 lines/min. It's kept anyway because some fatal errors (e.g. the 409 below) are only
  printed there.
- **Scratch folders** in `sessions/` are cleaned up after 14 days by `systemd-tmpfiles-clean`. Push
  anything you want to keep.
- **Revoking access:** remove the signing key and/or token on GitHub, or
  `sudo -u claude -H gh auth logout`. For Claude, `sudo -u claude -H claude auth logout`.

### Updating Claude Code

The auto-updater is disabled (`DISABLE_AUTOUPDATER=1`). On `server` the package comes from
`nixpkgs-unstable` (`pkgsUnstable` in `systems/server/configuration.nix`, with only `claude-code`
allowed as unfree; `inputs` reaches the server config through `specialArgs` in `flake.nix`). It
updates when `flake.lock` is updated. Stable nixpkgs lags well behind (2.1.223 vs 2.1.311 at the
time of writing).

After an update lands, restart the service to pick it up (`restartIfChanged = false`).

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Service restarts every 10s: `You must be logged in to use Remote Control` | Step 2 not done, or the login expired: `sudo -u claude -H claude auth login`. |
| `Remote Control requires claude.ai subscription auth` | An API key or token is in use. Don't set `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `CLAUDE_CODE_OAUTH_TOKEN`, `DISABLE_GROWTHBOOK`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` or `CLAUDE_CODE_DISABLE_FEATURE_FLAGS` in the unit or in `env` of any settings file. |
| `Workspace not trusted` | Run `claude` once interactively in `~/agents` as the `claude` user (step 2). |
| `Registration: Failed with status 409: This folder is already served by a terminal claude remote-control` | Seen when adding `--no-create-session-in-dir` while the previous server's sessions were still unarchived. Don't add that flag. Also check nothing else is running `claude remote-control` in `~/agents`. |
| Session says the clone failed on **SSH host key verification** | Something is using SSH. The service rewrites GitHub SSH URLs to HTTPS; if you see this, check the unit still has the `GIT_CONFIG_*` variables (`systemctl show claude-agents -p Environment`) and that the service was restarted after the rebuild. |
| Commits authored as `Claude <noreply@anthropic.com>` | The session overrode the identity because none was set. The service sets `GIT_AUTHOR_*`; restart it after rebuilding. |
| Commits **Unverified** | Signing key not added on GitHub as a *Signing Key*, or the commit email isn't verified on your account. |
| Push fails with credential errors after a nixpkgs update | Shouldn't happen with the env-based helper. If `~/.gitconfig` of `claude` has an old `/nix/store/.../gh` helper, it's ignored for github.com, but you can remove it. |

## Known limitations

- **One pre-created session.** The server always creates one session in `~/agents` itself, which
  takes a capacity slot (so 5 of 6 slots are for new sessions). `CLAUDE.md` tells that session to
  work in a new folder under `sessions/` if you use it. `--no-create-session-in-dir` would avoid
  this but triggers the 409 above.
- **The hook applies to every user on `server`.** For your own `claude --worktree` sessions there,
  the `worktree-<name>` branch isn't deleted when the worktree is removed (Claude Code never deletes
  branches created by a hook).
- **`-c` overrides.** A session could still bypass identity/signing with `git -c ...`; only
  `CLAUDE.md` asks it not to.
- **Auto-upgrade.** `system.autoUpgrade` builds `server` from the GitHub repo's default branch (`main`), so changes here only
  survive the nightly upgrade once merged.

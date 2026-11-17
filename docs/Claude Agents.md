# Claude Agents

The [`claude-agents`](../modules/services/claude-agents.nix) module turns a NixOS host into an agent
host: it runs a single `claude remote-control` server as a systemd service (`claude-agents`). From
the Claude mobile app or [claude.ai/code](https://claude.ai/code) you can start a session on that
host that behaves like a cloud agent:

1. The session starts in its own scratch folder, which is already an empty git repo so the Claude
   app's diff pane works (see [The WorktreeCreate hook](#the-worktreecreate-hook)).
2. It fetches whichever GitHub repo you name in your prompt into that folder (optionally with a
   default owner) and checks out the default branch.
3. It works on a `claude/<slug>` branch and commits locally (signed, as the configured identity).
4. It **doesn't push or open a PR on its own**: it asks whether you want the branch pushed and a
   draft PR opened, and only does both once you say so. Ask for a draft PR in your prompt to skip
   the question.

Sessions are sandboxed and can reach the internet but not the local network (see
[Network](#network) and [Sandboxing](#sandboxing)). Folders of inactive sessions are removed after
saving any unpushed work (see [Session cleanup](#session-cleanup)).

There is no per-repo configuration. Adding a new repo needs no changes here, only access for the
GitHub token (see [GitHub token](#github-token)).

Example:

```nix
services.claude-agents = {
  enable = true;
  name = "my-agents";                  # shown in claude.ai/code
  defaultOwner = "my-github-user";
  gitName = "Jane Doe";
  gitEmail = "jane@example.com";       # must be verified on GitHub for signed commits
};
```

## How it works

```
claude.ai/code / Claude app
        │  (outbound HTTPS only, no inbound ports)
        ▼
claude-agents.service  ── user `claude`, cwd /var/lib/claude/agents (not a git repo), sandboxed, no LAN
  claude remote-control --settings <settings.json> --name <name> --spawn worktree --capacity 6 --permission-mode acceptEdits
        │
        │ new session → WorktreeCreate hook (from the --settings file)
        ▼
/var/lib/claude/agents/sessions/<name>/   ← scratch folder per session, `git init`ed by the hook
        │  reads /var/lib/claude/agents/CLAUDE.md (picked up from the parent folder)
        ▼
git remote add origin https://github.com/owner/repo.git  →  git fetch  →  git remote set-head origin --auto
        ▼
checkout <default>  →  branch claude/<slug>  →  commit  →  (when asked) push  →  gh pr create --draft
```

| Piece | Where | Notes |
|---|---|---|
| Service | `systemd.services.claude-agents`, in `claude-agents.slice` | `restartIfChanged = false`, so a rebuild doesn't kill running agents. `Restart=always`. Sandboxed, only `/var/lib/claude` is writable (see [Sandboxing](#sandboxing)); no local network (see [Network](#network)). |
| User | `claude`, home `/var/lib/claude` | System user. Holds the Claude login, gh token and signing key. |
| Settings | `--settings /nix/store/…-claude-agents-settings.json` | `WorktreeCreate` hook + `permissions.allow` for `git`, `gh pr create`, `gh pr view`, `nix-shell`, `nix shell`, `nix develop`, `nix search`. Only for this service and its sessions, not for anyone else using Claude Code on the host. |
| Agent instructions | `/var/lib/claude/agents/CLAUDE.md` | Symlink into the Nix store (tmpfiles `L+`). The workflow sessions follow. |
| Scratch folders | `/var/lib/claude/agents/sessions/` | Removed as a whole by `claude-agents-cleanup.timer` after 14 days without changes (see [Session cleanup](#session-cleanup)). There is deliberately no `WorktreeRemove` hook. |
| Saved work | `/var/lib/claude/agents/archive/` | Git bundles of unpushed work from removed folders. Deleted by `systemd-tmpfiles` after 90 days. |
| Signing key | `/var/lib/claude/.ssh/signing_key` | ed25519, generated on first service start (`ExecStartPre`), never in the Nix store. |

### The WorktreeCreate hook

`--spawn worktree` normally needs a git repo. Instead the hook decides per call:

- **`cwd` is inside a git repo:** acts like Claude Code's default
  (`git worktree add -b worktree-<name> <top>/.claude/worktrees/<name>`). This keeps worktrees
  that sessions create themselves (subagent isolation, `EnterWorktree`) working.
- **Otherwise:** `mkdir -p <cwd>/sessions/<name>`, `git init -q` in it, and returns that. This is
  the agent-host case.

It prints only the path on stdout; everything else (including git's output) goes to stderr.

The `git init` is there for the diff pane in the Claude app, which needs the session's folder to be
in a git repo. A session whose folder wasn't a repo when it started is tagged `config:no-git-repo`
and gets no diff pane, even after the agent has put a repo there. Because the folder already has a
`.git`, `CLAUDE.md` tells the agent not to clone but to add `origin`, fetch,
`git remote set-head origin --auto`, check out the default branch from `origin/HEAD`, and then
create its `claude/<slug>` branch. The diff pane can then compare that branch against the default
branch.

**Picking up a changed hook or settings.** Remote Control reads the `--settings` file once, when it
starts. It pins the file's contents and refuses to start a session if the file is later missing or
different. The file is a store path, so it never changes, and `ExecStartPre` keeps the running
server's copy (and the hook it points to) from being garbage-collected with the GC root
`/nix/var/nix/gcroots/claude-agents-settings`. Because a rebuild doesn't restart the service
(`restartIfChanged = false`), the server keeps the old hook and permissions until you run
`sudo systemctl restart claude-agents` (this ends running sessions). `CLAUDE.md` takes effect for new
sessions without a restart.

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

`nix-shell`, `nix shell`, `nix develop` and `nix search` are pre-approved in the service's settings.
Because `--run` / `-c` take any command, this effectively lets sessions run any command without
asking, and `nix develop` also runs the repo's `shellHook`. The service sets `NIX_PATH` from
`nix.nixPath` (services don't get the login one), so `<nixpkgs>` resolves to the system's nixpkgs.
Unfree packages aren't allowed in these shells.

### Network

Sessions can reach the internet but not the local network. The service's `IPAddressDeny` blocks
private IPv4 (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`), the CGNAT range `100.64.0.0/10`
(also used by WireGuard and Tailscale), link-local, multicast and reserved ranges, and on IPv6
unique-local (`fc00::/7`, which includes Thread/Matter networks), link-local and multicast. systemd
enforces this with BPF on the service's cgroup, so it covers every process a session starts, and a
blocked connection fails straight away with "Operation not permitted". `CLAUDE.md` tells sessions
about it.

- **IPv6 on the LAN.** LAN devices have public IPv6 addresses, so they can't be blocked with a fixed
  range (and this repo is public, so the prefix isn't written down here).
  `claude-agents-block-site-ipv6` takes the host's global IPv6 addresses and on-link routes, widens
  each to its /48 (the most an ISP delegates to one site, so VLANs the host isn't on are covered
  too), and blocks those for `claude-agents.slice` with `systemctl set-property --runtime`. It runs
  before the server starts and every 15 minutes, to catch a late router advertisement or a new
  prefix. Check with `systemctl show claude-agents.slice -p IPAddressDeny`.
- **DNS** goes through systemd-resolved on `127.0.0.53`, which does the upstream lookups itself. The
  module asserts that resolved is enabled.
- **Loopback** stays reachable by default (`allowLoopback`), so sessions can run tests against
  servers or databases they start. That also reaches this host's own services that listen on all
  interfaces (Docker-published ports, Samba, NFS, SSH, ...), though not through its LAN address. Set
  `allowLoopback = false` to block loopback too, except for DNS.
- **Nix** builds and binary cache downloads are done by `nix-daemon`, which isn't in the service's
  cgroup, so they aren't affected (a binary cache on the LAN would still work).

### Sandboxing

The service and the cleanup job run with `ProtectSystem=strict` (only `/var/lib/claude` is writable),
`ProtectHome`, `PrivateTmp`, `PrivateDevices`, `PrivateIPC`, `ProtectProc=invisible` (other users'
processes are hidden), `ProtectKernelTunables`, `ProtectKernelModules`, `ProtectKernelLogs`,
`ProtectControlGroups`, `ProtectClock`, `ProtectHostname`, `NoNewPrivileges`, an empty capability
bounding set, `RestrictSUIDSGID`, `RestrictRealtime`, `LockPersonality`,
`SystemCallArchitectures=native`, and `RestrictAddressFamilies` limited to Unix, IPv4, IPv6 and
netlink sockets. With the network rules, `systemd-analyze security claude-agents` goes from 8.5
("EXPOSED") to 3.6 ("OK").

Left out because they break tools that sessions commonly run: `MemoryDenyWriteExecute` (JITs such as
node and bun), `RestrictNamespaces` and `SystemCallFilter` (Chromium's and bubblewrap's sandboxes,
debuggers), `ProcSubset=pid` (hides `/proc/cpuinfo` and `/proc/meminfo`, which build tools read) and
`PrivateUsers`.

### Session cleanup

`claude-agents-cleanup.timer` runs daily. It removes a session's folder, as a whole, once three
things are true: nothing in it has changed for `sessionRetentionDays` (14), nothing in the session's
transcript under `~/.claude/projects/` has either, and no running process has its working directory
in it. (This replaces aging the folders with `systemd-tmpfiles`, which deletes old files one at a
time: a session still in use after 14 days could lose files and git objects, unpushed commits
included.)

Before removing a folder, it saves whatever would be lost from each repo in it to
`/var/lib/claude/agents/archive/<folder>.bundle`: commits that aren't on a remote-tracking branch, a
detached `HEAD`, and uncommitted changes (untracked files too, ignored ones not) as
`refs/archive/uncommitted`. `<folder>.txt` next to it records the repo's origin. A folder with nothing
unpushed is removed without a bundle. If it can't save a repo's work (for example because the repo
is corrupt), it keeps the folder and the unit fails, so `systemctl --failed` shows it.

To restore saved work, in a clone of that repo:

```bash
sudo install -o "$USER" /var/lib/claude/agents/archive/<folder>.bundle /tmp/
git bundle list-heads /tmp/<folder>.bundle
git fetch /tmp/<folder>.bundle 'refs/*:refs/restored/*'   # and HEAD:restored-head if it's listed
```

A bundle only holds what wasn't on the remote, so the clone needs the commits it builds on
(`git bundle verify` checks).

### Git setup (all via the service environment)

Spawned sessions inherit these from the service, so nothing depends on `~/.gitconfig`:

- **Identity:** `GIT_AUTHOR_*` / `GIT_COMMITTER_*` from `services.claude-agents.gitName` /
  `gitEmail`. If unset, git uses the `claude` user's own git config.
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

All under `services.claude-agents`:

| Option | Default | |
|---|---|---|
| `enable` | `false` | |
| `package` | `pkgs.claude-code` | See [Updating Claude Code](#updating-claude-code). |
| `name` | `networking.hostName` | Name shown in claude.ai/code. |
| `capacity` | `6` | Max concurrent sessions, **including** the pre-created one (see [Known limitations](#known-limitations)). |
| `permissionMode` | `"acceptEdits"` | Permission mode for spawned sessions. |
| `defaultOwner` | `null` | GitHub owner assumed when the prompt doesn't name one. |
| `gitName` / `gitEmail` | `null` | Commit author/committer. Set both or neither. |
| `signCommits` | `true` | Sign commits and tags with the dedicated SSH key. |
| `sessionRetentionDays` | `14` | Remove a session's folder after this many days without changes. See [Session cleanup](#session-cleanup). |
| `allowLoopback` | `true` | Let sessions connect to `localhost`. See [Network](#network). |

## Setup procedure

### 1. Deploy

Enable the module and run `nixos-rebuild switch`.

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

Run these from a directory the `claude` user can read (for example not inside your home
directory), otherwise git prints `failed to stat` errors.

- `claude auth login` **must** be a claude.ai subscription login. API keys, `ANTHROPIC_AUTH_TOKEN`,
  `apiKeyHelper` and `claude setup-token` / `CLAUDE_CODE_OAUTH_TOKEN` tokens can't establish Remote
  Control sessions.
- The trust and consent prompts must be answered once interactively. Without a TTY the service
  can't answer them and exits (`Workspace not trusted`).
- `gh auth setup-git` isn't needed: the credential helper is set by the service.

#### GitHub token

Use a **fine-grained personal access token** limited to your repos, with:

- **Contents:** read and write (fetch, push)
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

The host should appear under its `name` in the Code tab of the app / claude.ai/code. Start a
**new** session with something like:

> in &lt;repo&gt;, add a comment to the README and open a draft PR

Then check:

```bash
sudo -u claude bash -c 'cd /var/lib/claude/agents/sessions && for d in */; do
  echo "$d: $(git -C "$d" branch --show-current 2>/dev/null) $(git -C "$d" log -1 --format="%an <%ae> sig=%G?" 2>/dev/null)"
done'
```

Expect a `bridge-<session id>` folder on a `claude/...` branch, authored as `gitName`/`gitEmail`,
and a draft PR whose commit shows Verified.

## Operations

- **Rebuilds don't restart the service** (`restartIfChanged = false`). To apply changes to the unit,
  `sudo systemctl restart claude-agents`. This ends running sessions.
- **Logs:** `journalctl -u claude-agents`. The server redraws its status screen into stdout, so
  expect ~80 lines/min. It's kept anyway because some fatal errors (e.g. the 409 below) are only
  printed there.
- **Scratch folders** in `sessions/` are removed after 14 days without changes, and unpushed work
  is saved to `archive/` for another 90 days (see [Session cleanup](#session-cleanup)). Agents don't
  push unless asked, so ask the session to push anything you want to keep. Cleanup runs are logged
  in `journalctl -u claude-agents-cleanup`.
- **Revoking access:** remove the signing key and/or token on GitHub, or
  `sudo -u claude -H gh auth logout`. For Claude, `sudo -u claude -H claude auth logout`.

### Updating Claude Code

The auto-updater is disabled (`DISABLE_AUTOUPDATER=1`); the version is whatever `package` is.
`claude-code` moves fast and stable nixpkgs can lag well behind, so consider taking it from
`nixpkgs-unstable` (it's unfree, so that nixpkgs instance needs to allow it):

```nix
services.claude-agents.package =
  (import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-code";
  }).claude-code;
```

After an update lands, restart the service to pick it up (`restartIfChanged = false`).

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| Service restarts every 10s: `You must be logged in to use Remote Control` | Step 2 not done, or the login expired: `sudo -u claude -H claude auth login`. |
| `Remote Control requires claude.ai subscription auth` | An API key or token is in use. Don't set `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `CLAUDE_CODE_OAUTH_TOKEN`, `DISABLE_GROWTHBOOK`, `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` or `CLAUDE_CODE_DISABLE_FEATURE_FLAGS` in the unit or in `env` of any settings file. |
| `Workspace not trusted` | Run `claude` once interactively in `~/agents` as the `claude` user (step 2). |
| `Registration: Failed with status 409: This folder is already served by a terminal claude remote-control` | Seen when adding `--no-create-session-in-dir` while the previous server's sessions were still unarchived. Don't add that flag. Also check nothing else is running `claude remote-control` in `~/agents`. |
| Session says the fetch failed on **SSH host key verification** | Something is using SSH. The service rewrites GitHub SSH URLs to HTTPS; if you see this, check the unit still has the `GIT_CONFIG_*` variables (`systemctl show claude-agents -p Environment`) and that the service was restarted after the rebuild. |
| Commits authored as `Claude <noreply@anthropic.com>` | The session overrode the identity because none was set. The service sets `GIT_AUTHOR_*`; restart it after rebuilding. |
| Commits **Unverified** | Signing key not added on GitHub as a *Signing Key*, or the commit email isn't verified on your account. |
| A session can't reach something on the LAN, or gets "Operation not permitted" connecting to a private address | Expected, see [Network](#network). |
| Session doesn't start: `The settings file … has changed since Remote Control started` or `Settings file not found` | The server's `--settings` file was deleted or replaced, which the GC root should prevent. Restart the service. |
| `claude-agents-cleanup.service` failed | It couldn't save the unpushed work in a folder, so it kept it. `journalctl -u claude-agents-cleanup` names the folder. Rescue or delete it by hand. |
| Push fails with credential errors after a nixpkgs update | Shouldn't happen with the env-based helper. If `~/.gitconfig` of `claude` has an old `/nix/store/.../gh` helper, it's ignored for github.com, but you can remove it. |

## Known limitations

- **One pre-created session.** The server always creates one session in `~/agents` itself, which
  takes a capacity slot (so `capacity - 1` slots are for new sessions). `CLAUDE.md` tells that session to
  work in a new folder under `sessions/` if you use it. `--no-create-session-in-dir` would avoid
  this but triggers the 409 above.
- **Worktree branches stay.** For worktrees that sessions create themselves, the `worktree-<name>`
  branch isn't deleted when the worktree is removed (Claude Code never deletes branches created by
  a hook).
- **IPv6 prefixes are a guess.** Blocking the /48 around the host's own prefixes doesn't cover a
  site with a larger delegation or unrelated extra prefixes. A prefix the host no longer has stays
  blocked until the next reboot.
- **Loopback.** With `allowLoopback` (the default), this host's services that listen on all
  interfaces are reachable through `localhost`.
- **`-c` overrides.** A session could still bypass identity/signing with `git -c ...`; only
  `CLAUDE.md` asks it not to.

# Boot safety net for the homelab server.
#
# Two independent, complementary mechanisms:
#
#   1. systemd-boot Automatic Boot Assessment (boot counting). [DISABLED on 26.05]
#      Requires nixpkgs >= 26.11; see the commented option below.
#      Catches failures that happen *during* boot (panic, initrd/ZFS failure,
#      systemd never reaching userspace). The bootloader gives a freshly
#      written generation N tries; if the boot never reaches
#      `boot-complete.target`, systemd-bless-boot never marks it good, the
#      counter hits zero, and systemd-boot skips it in favour of an older
#      generation. No script involved -- a script cannot help here because it
#      never runs.
#
#   2. A "dead man's switch" (this file's systemd units).
#      Catches the case where userspace *did* come up but the homelab was
#      never brought online -- i.e. you did not run `start-homelab` within
#      five minutes of boot. On expiry it points the *next* boot at the
#      previous generation (one-shot only, default entry untouched) and
#      reboots. `start-homelab` disarms it by writing a per-boot stamp.
#
# Loop safety: the dead man's switch only arms when the *newest* generation is
# booted (the one you are testing). Once it has reverted you onto an older
# generation it stands down, so it reverts at most one step rather than walking
# the machine backwards through generations.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  confirmStamp = "/run/homelab-confirmed";

  rollback = pkgs.writeShellApplication {
    name = "homelab-rollback";
    runtimeInputs = with pkgs; [
      coreutils
      jq
      systemd
    ];
    text = ''
      # Homelab was confirmed healthy this boot -- nothing to do.
      if [ -e "${confirmStamp}" ]; then
        echo "homelab-rollback: confirmed this boot, standing down"
        exit 0
      fi

      booted=$(readlink -f /run/booted-system)
      if [ -z "$booted" ]; then
        echo "homelab-rollback: cannot resolve /run/booted-system, standing down" >&2
        exit 1
      fi

      # Map generation profile links to numbers; find the booted one and the
      # newest one.
      cur=""
      newest=""
      prev=""
      for link in /nix/var/nix/profiles/system-*-link; do
        [ -e "$link" ] || continue
        n=''${link#/nix/var/nix/profiles/system-}
        n=''${n%-link}
        case "$n" in
          "" | *[!0-9]*) continue ;;
        esac
        if [ -z "$newest" ] || [ "$n" -gt "$newest" ]; then newest=$n; fi
        if [ "$(readlink -f "$link")" = "$booted" ]; then cur=$n; fi
      done

      if [ -z "$cur" ]; then
        echo "homelab-rollback: booted system is not a tracked generation (specialisation?), standing down" >&2
        exit 1
      fi

      # Only arm on the newest generation. If we are already on an older one we
      # have probably reverted here on purpose -- do not walk further back.
      if [ "$cur" != "$newest" ]; then
        echo "homelab-rollback: booted generation $cur is not the newest ($newest), standing down"
        exit 0
      fi

      for link in /nix/var/nix/profiles/system-*-link; do
        [ -e "$link" ] || continue
        n=''${link#/nix/var/nix/profiles/system-}
        n=''${n%-link}
        case "$n" in
          "" | *[!0-9]*) continue ;;
        esac
        if [ "$n" -lt "$cur" ] && { [ -z "$prev" ] || [ "$n" -gt "$prev" ]; }; then
          prev=$n
        fi
      done

      if [ -z "$prev" ]; then
        echo "homelab-rollback: no previous generation to revert to, standing down" >&2
        exit 1
      fi

      # Resolve the bootloader entry id for generation $prev. Entry filenames
      # are content-hashed (nixos-<sha256>.conf); the generation number lives in
      # the "version" field ("Generation N ..."). Ask bootctl for the
      # authoritative id rather than guessing the filename.
      entry_id=$(bootctl list --json=short 2>/dev/null | jq -r \
        --argjson cur "$cur" '
          [ .[]
            | select(.version != null)
            | (.version | capture("Generation (?<n>[0-9]+)") | .n | tonumber) as $gen
            | select($gen < $cur)
            | { id: .id, gen: $gen }
          ] | sort_by(.gen) | last | .id // empty')

      if [ -z "$entry_id" ]; then
        echo "homelab-rollback: could not resolve boot entry for generation $prev, standing down" >&2
        exit 1
      fi

      echo "homelab-rollback: homelab not confirmed within deadline; reverting boot from generation $cur to $prev (entry $entry_id) and rebooting"
      bootctl set-oneshot "$entry_id"
      systemctl reboot
    '';
  };
in
{
  # Mechanism 1: boot counting (bootloader-level, catches boot-time failures).
  #
  # NOTE: `boot.loader.systemd-boot.bootCounting` only exists in nixpkgs >= 26.11.
  # This host is pinned to nixos-26.05, so the option is unavailable and the line
  # below is commented out. Uncomment it after moving nixpkgs to 26.11+ to get
  # automatic fallback when a generation fails to reach boot-complete.target.
  #
  # boot.loader.systemd-boot.bootCounting.enable = true;

  # Mechanism 2: dead man's switch (catches "userspace up but homelab not
  # brought online within the deadline").
  systemd.services.homelab-rollback = {
    description = "Revert to previous NixOS generation if the homelab was not confirmed after boot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe rollback;
    };
  };

  systemd.timers.homelab-rollback = {
    description = "Deadline to confirm the homelab is healthy after boot (run start-homelab)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      AccuracySec = "1s";
    };
  };
}

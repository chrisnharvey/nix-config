#!/usr/bin/env bash

# Confirm this boot is healthy so the boot rollback guard stands down.
# (See systems/server/rollback-guard.nix.) Do this first: running this command
# is the "I am here and in control" signal, regardless of what follows.
touch /run/homelab-confirmed
systemctl stop homelab-rollback.timer 2>/dev/null || true

zfs-multi-mount data/data vms/data vms/docker
systemctl restart docker.service

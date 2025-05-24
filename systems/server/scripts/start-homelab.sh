#!/usr/bin/env bash

zfs-multi-mount data/data vms/vms vms/docker
systemctl restart docker.service
systemctl start duplicacy-web.service
virsh -c qemu:///system start hass
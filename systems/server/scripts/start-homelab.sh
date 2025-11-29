#!/usr/bin/env bash

zfs-multi-mount data/data vms/data vms/docker
systemctl restart docker.service

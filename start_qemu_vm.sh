#!/usr/local/bin/bash

qemu-system-x86_64 -m 4096m -cdrom FreeBSD14.1_bootonly.iso -net nic -net tap,ifname=tap0 -boot d


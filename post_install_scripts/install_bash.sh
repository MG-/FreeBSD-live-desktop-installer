#!/bin/sh

echo "0-------------------------------------------0"
echo "| install bash shell  and set as root shell |"
echo "0-------------------------------------------0"
pkg install -y bash
[ -f /usr/local/bin/bash ] && chsh -s bash


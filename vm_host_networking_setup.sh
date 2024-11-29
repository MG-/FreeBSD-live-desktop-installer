#!/usr/local/bin/bash

# 0---------------------------------------------------------0
# | Networking setup that makes Qemu or Virtualbox act like |
# | a local computer. DHCP is required inside.              |
# 0---------------------------------------------------------0

# 0----------------------------------------------------------------0
# | Assume host's 1st network interface is the internet connection |
# 0----------------------------------------------------------------0
NIC="$(ifconfig -l | tr ' ' '\n' | grep -v lo0 | head -n1)"

# 0----------------------------------------0
# | Create tap0 device if it doesn't exist |
# | also, 2 sysctl settings are needed:    |
# 0----------------------------------------0
if [ -z "$(ifconfig | grep tap0)" ]
then
  ifconfig tap0 create
  ifconfig tap0 up
fi
sysctl net.link.tap.user_open=1
sysctl net.link.tap.up_on_open=1

# 0-------------------------------------------0
# | Create bridge0 device if it doesn't exist |
# | Add active NIC and tap device to bridge0  |
# 0-------------------------------------------0
if [ -z "$(ifconfig | grep bridge0)" ]
then
  ifconfig bridge0 create
  ifconfig bridge0 addm $NIC
  ifconfig bridge0 addm tap0
  ifconfig bridge0 up
fi

# 0--------------------------------------------------------------------0
# | init triggers for qemu to activate/deactivate stateless tap device |
# 0--------------------------------------------------------------------0
ln -fs /usr/bin/true /usr/local/etc/qemu-ifup
ln -fs /usr/bin/true /usr/local/etc/qemu-ifdown
chmod u+x /usr/local/etc/qemu-if*


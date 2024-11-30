# to do:
# - block script execution on the host. It will mount tmpfs on everything
#   We must be a vm.

echo "0----------------------------------------------------------------0"
echo "| script: internal.sh                                            |"
echo "| prepare dirs that have to be writable for                      |"
echo "| package installation and x.org startup                         |"
echo "0----------------------------------------------------------------0"

mount -t tmpfs tmpfs /tmp
mount -t tmpfs tmpfs /usr/local
mount -t tmpfs tmpfs ~
cp -R /etc /tmp
# remove original symlink to now disappeared /tmp content
# (otherwise we're stuck with a read-only resolv.conf)
rm /tmp/etc/resolv.conf
mkdir -p /tmp/var/db
mkdir -p /tmp/var/log
mkdir -p /tmp/var/run
mkdir -p /tmp/usr/local
mount_nullfs /tmp/etc /etc
mount_nullfs /tmp/var /var
mount_nullfs /tmp/usr/local /usr/local

echo "0-------------------------------------------------------------------0"
echo "| Set resolv.conf nameserver ip to the gateway ip given by dhclient |"
echo "0-------------------------------------------------------------------0"
NIC=$(ifconfig -l | tr ' ' '\n' | grep -v lo0 | head -n1)
GATEWAY=$(route show default | grep "gateway:" | tr -s ' ' | cut -d ' ' -f 3)
echo "nameserver $GATEWAY" > /etc/resolv.conf

echo "0-----------------------------------------0"
echo "| install required packages for a minimal |"
echo "| X.org screen with Xtern and openbox wm  |"
echo "0-----------------------------------------0"
pkg install -y xorg-server openbox xterm xset xinit xf86-input-evdev xf86-video-vesa xf86-video-scfb

echo "0-----------------------------------------------0"
echo "| X.org startscript, executed by startx command |"
echo "0-----------------------------------------------0"
(
  echo "xset r rate 170 100" # extreme keyboard input, not required
  echo "xterm -bg black -fg green &"
  echo "openbox"
) > ~/.xinitrc

echo "0----------------------------------------------0"
echo "| add /usr/local/lib to the system dll         |"
echo "| locations to make the new packages available |"
echo "0----------------------------------------------0"
ldconfig -R /usr/local/lib

echo "0---------------------------------------------------------0"
echo "| psm0 is the virtual mouse device of Qemu and Virtualbox |"
echo "0---------------------------------------------------------0"
moused -p /dev/psm0

echo "0---------------------------------------------------0"
echo "| load vesa kernel module for legacy X.org graphics |"
echo "0---------------------------------------------------0"
kldload vesa

echo "0----------------------------------------------------------------0"
echo "| install git and download full repository of this project into ~|"
echo "0----------------------------------------------------------------0"
pkg install -y git
git clone https://github.com/mg-/freebsd-live-desktop-installer
chmod u+x ~/freebsd-live-desktop-installer/post_install_scripts/*


# 0-----------------------------------------------------------0
# | Determine system platform                                 |
# 0-----------------------------------------------------------0
# | This code doesn't do anything at the moment.              |
# | It's a first setup idea for a                             |
# | platform/hardware detection system                        |
# |                                                           |
# | Current status:                                           |
# |   3 systems are now implemented: qemu, virtualbox, bhyve. |
# |   Based on the dmesg output we can find out if we booted  |
# |   as any of these.                                        |
# |   If that is the case, the supported system is added to   |
# |   variable $system_platform.                              |
# |   Because very similar systems can get supported, this    |
# |   can result in multiple positives.                       |
# |   If this variable contains multiple systems at the end,  |
# |   that means it has to be specified better. Only 1        |
# |   may remain, so we know exactly what to do for the       |
# |   currently booted system.                                |
# |   Based on this information, system-specific actions      |
# |   like installation and configuration of things related   |
# |   to graphical output and media can be added per          |
# |   supported systems                                       |
# 0-----------------------------------------------------------0
system_platform=""
if [ -n "$(dmesg | grep "Hypervisor: Origin = \"bhyve bhyve \"")" ]
then
  system_platform="${system_platform}[bhyve]"
fi
if [ -n "$(dmesg | grep "CPU: QEMU Virtual CPU")" ]
then
  system_platform="${system_platform}[qemu]"
fi
if [ -n "$(dmesg | grep "ACPI APIC Table: <VBOX   VBOXAPIC>")" ]
then
  system_platform="${system_platform}[virtualbox]"
fi
echo "0-----------------------------------------0"
echo "| final content system_platform variable: |"
echo "0-----------------------------------------0"
echo "$system_platform"








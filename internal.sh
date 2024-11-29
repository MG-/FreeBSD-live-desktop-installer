# 0----------------------------------------------------------------0
# | prepare dirs that have to be writable for                      |
# | package installation and x.org startup                         |
# 0----------------------------------------------------------------0
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

# 0-------------------------------------------------------------------0
# | Set resolv.conf nameserver ip to the gateway ip given by dhclient |
# 0-------------------------------------------------------------------0
NIC=$(ifconfig -l | tr ' ' '\n' | grep -v lo0 | head -n1)
GATEWAY=$(route show default | grep "gateway:" | tr -s ' ' | cut -d ' ' -f 3)
echo "nameserver $GATEWAY" > /etc/resolv.conf

# 0--------------------------------------------------------------------------------0
# | install required packages for a minimal X.org screen with Xtern and openbox wm |
# 0--------------------------------------------------------------------------------0
pkg install -y xorg-server openbox xterm xset xinit xf86-input-evdev xf86-video-vesa

# 0-----------------------------------------------0
# | X.org startscript, executed by startx command |
# 0-----------------------------------------------0
(
  echo "xset r rate 170 100" # extreme keyboard input, not required
  echo "xterm -bg black -fg green &"
  echo "openbox"
) > ~/.xinitrc

# 0-----------------------------------------------------------------------------------0
# | add /usr/local/lib to the system dll locations to make the new packages available |
# 0-----------------------------------------------------------------------------------0
ldconfig -R /usr/local/lib

# 0---------------------------------------------------------0
# | psm0 is the virtual mouse device of Qemu and Virtualbox |
# 0---------------------------------------------------------0
moused -p /dev/psm0

# 0---------------------------------------------------0
# | load vesa kernel module for legacy X.org graphics |
# 0---------------------------------------------------0
kldload vesa

echo "0----------------------------------------------------------0"
echo "| install git and download full repository of this project |"
echo "0----------------------------------------------------------0"
pkg install -y git
git clone https://github.com/mg-/freebsd-live-desktop-installer

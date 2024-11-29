echo "0----------------------------------------------------------------0"
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
pkg install -y xorg-server openbox xterm xset xinit xf86-input-evdev xf86-video-vesa

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

echo "0----------------------------------------------------------0"
echo "| install git and download full repository of this project |"
echo "0----------------------------------------------------------0"
pkg install -y git
git clone https://github.com/mg-/freebsd-live-desktop-installer
chmod u+x ~/freebsd-live-desktop-installer/post_install_scripts/*


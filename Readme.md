FreeBSD 14.1 automated installation of a X.org graphical environment

This is an experimental set of scripts that's supposed to auto-install
a basic graphical X screen from the "live shell" command-line that can be
chosen in the FreeBSD 14.1 boot-only iso. (And most other iso's)
The system will run fully in RAM, so there's no permanent storage,
At this moment this automation only exists for Qemu and Virtualbox.

Requirements:
- Any amd64/FreeBSD 14.1 testing workstation to run Qemu or Virtualbox
- Bash shell package. (Not really required but it's what this is tested with)
- A standard ipv4 LAN with DHCP server and internet connection.
- A FreeBSD 14.1 RELEASE bootonly ISO file.
- The internal.sh script that has to be downloaded from within the live shell.
- preparation required for Virtualbox only:
  (1) Create a vm without disk and give it 4GB RAM.
  (2) Change networking setting to: bridged adapter, name tap0
  (3) (Storage) Attach the FreeBSD bootonly iso as cdrom

How to use:
- Run the script vm_host_networking_setup.sh 1 time to prepare the bridge adapter that both
  Qemu and Virtualbox can use.
- Start Qemu with command:
  qemu-system-x86_64 -m 4096m -cdrom FreeBSD14.1_bootonly.iso -net nic -net tap,ifname=tap0 -boot d
  Or start Virtualbox with the same ISO.

Inside the virtual machine:
(1) init internet connection: dhclient em0
(2) get the internal.sh script somehow from a local network location and run it.
(3) type startx to start a minimal X.org.
    (Don't close the initial xterm. It's the only I/O during this testing X session)
    At this point it's also possible to install a full desktop like xfce  but you need
    more than 4GB RAM for that.

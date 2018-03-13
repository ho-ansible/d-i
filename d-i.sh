#! /bin/sh
# wget -O- https://d-i.seanho.com/d-i.sh | bash -
## Configure grub for auto-install of Debian from ISO

repo=https://github.com/ho-ansible/d-i
iso=https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.4.0-amd64-netinst.iso

cd /boot
wget -N "$iso"
git clone $repo
cd $(basename $repo)

install -Cv -o root -g root -m 755 grub.d/* /etc/grub.d/
update-grub

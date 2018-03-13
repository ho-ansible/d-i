#! /bin/sh
# wget -O- https://d-i.seanho.com/d-i.sh | bash -
## Configure grub for auto-install of Debian from ISO

repo="https://github.com/ho-ansible/d-i"
ver="9.4.0"
arch="amd64"
iso="https://cdimage.debian.org/debian-cd/current/$arch/iso-cd/debian-$ver-$arch-netinst.iso"

cd /boot
wget -N "$iso"
git clone $repo
cd $(basename $repo)

install -Cv -o root -g root -m 755 grub.d/* /etc/grub.d/
update-grub

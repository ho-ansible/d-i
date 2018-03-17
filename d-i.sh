#! /bin/sh
# wget -O- https://d-i.seanho.com/d-i.sh | bash -
## Configure grub for auto-install of Debian from ISO

ver="9.4.0"
arch="amd64"
iso="https://cdimage.debian.org/debian-cd/current/$arch/iso-cd/debian-$ver-$arch-netinst.iso"

repo="https://github.com/ho-ansible/d-i"

cd /boot
wget -N "$iso"
git clone --depth 1 $repo
cd $(basename $repo)

install -Cv -o root -g root -m 755 grub.d/* /etc/grub.d/
update-grub

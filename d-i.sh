#! /bin/sh
# wget -O- https://d-i.seanho.com/d-i.sh | bash -
## Configure grub for Debian netinstall

arch="amd64"
url="http://ftp.debian.org/debian/dists/stable/main/installer-$arch/current/images/netboot/debian-installer/$arch"

repo="https://github.com/ho-ansible/d-i"

cd /boot
git clone --depth 1 $repo
cd $(basename $repo)

for file in linux initrd.gz; do
  wget "$url/$file"
done

install -Cv -o root -g root -m 755 grub.d/* /etc/grub.d/
update-grub

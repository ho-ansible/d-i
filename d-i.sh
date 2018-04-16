#! /bin/sh
## Configure grub for Debian netinstall

arch="amd64"
url="http://ftp.debian.org/debian/dists/stable/main/installer-$arch/current/images/netboot/debian-installer/$arch"

repo="https://github.com/ho-ansible/d-i"

cd /boot
repodir=$(basename $repo)
if [ -d "$repodir/.git" ]; then
  cd "$repodir"
  git pull
else
  git clone --depth 1 $repo
  cd "$repodir"
fi

for file in linux initrd.gz; do
  wget -N "$url/$file"
done

install -Cv -o root -g root -m 755 grub.d/* /etc/grub.d/
update-grub

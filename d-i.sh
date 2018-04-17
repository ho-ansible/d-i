#! /bin/sh
## Configure grub for Debian netinstall

arch="amd64"
url="http://ftp.debian.org/debian/dists/stable/main/installer-$arch/current/images/netboot/debian-installer/$arch"

repo="https://github.com/ho-ansible/d-i"

apt-get -qq install git wget gettext-base

# Clone git repo, use as working dir
cd /boot
repodir=$(basename $repo)
if [ -d "$repodir/.git" ]; then
  cd "$repodir"
  git pull
else
  git clone --depth 1 $repo
  cd "$repodir"
fi

# Download Debian netboot kernel/ramdisk
for file in linux initrd.gz; do
  wget -N "$url/$file"
done

# Configure GRUB2
install -Cv -o root -g root -m 755 grub.d/* /etc/grub.d/
update-grub

# Read current network config

# sets $dev, $src, and $via
eval x=$(ip ro get 8.8.8.8 | sed 's/\([a-z]\)\s\+/\1=/g')
export IPADDRESS="$src"
export GATEWAY="${via:-}"

export NAMESERVERS="8.8.8.8"
export HOSTNAME=$(hostname -s)
HOSTNAME="${HOSTNAME:-debian}"
export DOMAIN=$(hostname -d)
DOMAIN="${DOMAIN:-example.com}"

# Other variables for preseed.cfg
export AUTH_KEYS_URL="https://f.seanho.com/vps/authorized_keys"
export DMCRYPT_PASS="3ChcPn7nTdjlvLUw6WgH"

# Process preseed file: envsubst is in gettext-base
envsubst < d-i/stretch/preseed.cfg > preseed.cfg


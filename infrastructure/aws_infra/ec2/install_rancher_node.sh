#!/bin/bash

INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Mount ebs volume
# ---
# Create file system
mkfs -t xfs /dev/xvdf
# Create the directory to mount to
mkdir -p /var/lib/rancher/
# Mount the ebs volume
mount /dev/xvdf /var/lib/rancher/

cp /etc/fstab /etc/fstab.orig
DEVICE_UUID=$(blkid -s UUID -o value /dev/xvdf)

# Add entry to fstab if it doesn't already exist
if ! grep -q "$DEVICE_UUID" /etc/fstab; then
  echo "UUID=$DEVICE_UUID  /data  xfs  defaults,nofail  0  2" >> /etc/fstab
fi

# Mount all filesystems in fstab
mount -a

mkdir -p /etc/rancher/rke2/

touch /etc/rancher/rke2/config.yaml

cat <<EOF > /etc/rancher/rke2/config.yaml
token: my-secret-token
server: https://${rke2_master_dns}:9345
tls-san:
    - ${rke2_master_dns}
    - ${internal_dns}
    - ${load_balancer_dns}
    - $INSTANCE_IP
EOF

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service

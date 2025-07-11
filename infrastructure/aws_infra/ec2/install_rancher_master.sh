#!/bin/bash

sudo apt install unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

ALLOCATE_ID="${allocation_id}"

# Release the EIP if it is currently associated with an instance
aws ec2 disassociate-address --association-id "$ALLOCATE_ID" || true

# Associate address to this instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 associate-address --instance-id "$INSTANCE_ID" --allocation-id "$ALLOCATE_ID"

curl https://releases.rancher.com/install-docker/28.1.1.sh | sh

sudo usermod -aG docker ubuntu

mkdir -p /etc/rancher/rke2/

cat <<EOF > /etc/rancher/rke2/config.yaml
token: my-secret-token
tls-san:
    - ${ip_address}
EOF

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
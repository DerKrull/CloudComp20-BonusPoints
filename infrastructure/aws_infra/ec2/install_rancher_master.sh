#!/bin/bash

curl https://releases.rancher.com/install-docker/28.1.1.sh | sh

sudo usermod -aG docker ubuntu

mkdir -p /etc/rancher/rke2/

cat <<EOF > /etc/rancher/rke2/config.yaml
token: my-secret-token
tls-san:
    - my-rancher-server.example.com
EOF

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
#!/bin/bash

mkdir -p /etc/rancher/rke2/

touch /etc/rancher/rke2/config.yaml

cat <<EOF > /etc/rancher/rke2/config.yaml
token: my-secret-token
server: https://${rke2_master_dns}:9345
tls-san:
    - ${rke2_master_dns}
    - ${internal_dns}
    - ${load_balancer_dns}
EOF

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
systemctl enable rke2-agent.service
systemctl start rke2-agent.service

#!/bin/bash

INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)



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

#!/bin/bash

cat <<EOF > /etc/rancher/rke2/config.yaml
token: my-secret-token
server: https://${lb_dns_name}:9345
tls-san:
    - my-rancher-server.example.com
EOF

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service
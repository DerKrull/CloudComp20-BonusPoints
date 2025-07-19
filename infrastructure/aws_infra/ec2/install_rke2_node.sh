#!/bin/bash

# Update or create a Route53 record for the instance
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

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

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service

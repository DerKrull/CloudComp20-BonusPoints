#!/bin/bash

sudo apt install unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Update or create a Route53 record for the instance
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat > change-batch.json <<EOF
{
    "Comment": "Update record to point to Rancher master",
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "${record_name}",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [
                    {
                        "Value": "$INSTANCE_IP"
                    }
                ]
            }
        }
    ]
}
EOF

aws route53 change-resource-record-sets --hosted-zone-id "${hosted_zone_id}" --change-batch file://change-batch.json
rm change-batch.json

# Install Docker
curl https://releases.rancher.com/install-docker/28.1.1.sh | sh

sudo snap install yq

sudo usermod -aG docker ubuntu

# Install RKE2
# ---
mkdir -p /etc/rancher/rke2/

cat <<EOF > /etc/rancher/rke2/config.yaml
token: my-secret-token
tls-san:
    - ${record_name}
    - ${load_balancer_dns}
    - ${internal_dns}
    - $INSTANCE_IP
EOF

mkdir -p /var/lib/rancher/rke2/server/manifests/

# Write cert-manager manifest
cat <<EOF > /var/lib/rancher/rke2/server/manifests/cert-manager.yaml
${cert_manager}
EOF

# Write Rancher manifest
cat <<EOF > /var/lib/rancher/rke2/server/manifests/rancher.yaml
${rancher}
EOF

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service

# Wait until the kubeconfig exists
while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do sleep 2; done

# Upload the fixed kubeconfig
aws s3 cp /etc/rancher/rke2/rke2.yaml s3://cloudcomp20-terraform-state-bucket/rke2.yaml

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
export PATH=$PATH:/usr/local/bin

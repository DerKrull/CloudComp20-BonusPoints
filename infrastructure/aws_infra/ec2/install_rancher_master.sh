#!/bin/bash

sudo apt install unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Update or create a Route53 record for the instance

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

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

curl https://releases.rancher.com/install-docker/28.1.1.sh | sh

sudo usermod -aG docker ubuntu

mkdir -p /etc/rancher/rke2/

cat <<EOF > /etc/rancher/rke2/config.yaml
token: my-secret-token
tls-san:
    - ${load_balancer_dns}
    - ${internal_dns}
EOF

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service

aws s3 cp /etc/rancher/rke2/rke2.yaml s3://cloudcomp20-terraform-state-bucket/rke2.yaml

# Wait for kubeconfig file
while [ ! -f /etc/rancher/rke2/rke2.yaml ]; do
    sleep 2
done

export PATH=$PATH:/var/lib/rancher/rke2/bin

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
export PATH=$PATH:/usr/local/bin
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# Install Rancher
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

kubectl  --kubeconfig /etc/rancher/rke2/rke2.yaml create namespace cattle-system

# If you have installed the CRDs manually, instead of setting `installCRDs` or `crds.enabled` to `true` in your Helm install command, you should upgrade your CRD resources before upgrading the Helm chart:
kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.crds.yaml

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=false \

# Install Rancher
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=${load_balancer_dns} \
  --set bootstrapPassword=admin

kubectl -n cattle-system rollout status deploy/rancher
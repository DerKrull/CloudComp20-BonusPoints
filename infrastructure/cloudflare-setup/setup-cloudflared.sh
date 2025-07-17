# Install cloudflared
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list

sudo apt-get update && sudo apt-get install cloudflared

cloudflared tunnel login
cloudflared tunnel create openstack-tunnel

export KUBECONFIG=../CloudComp20-k8s.rke2.yaml

kubectl create secret generic cloudflared-secret   --from-file=config.yaml=config.yaml   --from-file=583b54e6-a3eb-4ac0-94be-4cb163ad39af.json=/home/felix/.cloudflared/583b54e6-a3eb-4ac0-94be-4cb163ad39af.json

kubectl create -f cloudflare-token.yaml
kubectl get secrets
kubectl create -f cloudflared.yaml
kubectl get all

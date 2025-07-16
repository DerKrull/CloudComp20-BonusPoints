kubectl --kubeconfig=../rke2.yaml create -f tunnel-token.yaml
kubectl --kubeconfig=../rke2.yaml get secrets
kubectl --kubeconfig=../rke2.yaml create -f tunnel.yaml
kubectk --kubeconfig=../rke2.yaml get all

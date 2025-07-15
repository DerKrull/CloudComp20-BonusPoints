apiVersion: v1
kind: Namespace
metadata:
  name: cattle-system
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: rancher
  namespace: kube-system
spec:
  chart: rancher
  repo: https://releases.rancher.com/server-charts/latest
  targetNamespace: cattle-system
  version: 2.11.3
  valuesContent: |-
    hostname: ${load_balancer_dns}
    replicas: 3
    bootstrapPassword: admin
    ingress:
      ingressClassName: nginx

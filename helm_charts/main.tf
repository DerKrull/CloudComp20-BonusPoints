provider "helm" {
  kubernetes = {
    config_path = "${path.module}/../infrastructure/rke2.yaml"
  }
}

terraform {
  backend "s3" {
    bucket = "cloudcomp20-terraform-state-bucket"
    region = "us-east-1"
    key = "helm/cloudcomp20.tfstate"
  }
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
    }
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  set = [{
    name  = "crds.enabled"
    value = "false"
  }]
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  namespace  = "cattle-system"
  create_namespace = true

  set = [
    {
        name  = "hostname"
        value = var.load_balancer_dns
    },
    {
        name  = "bootstrapPassword"
        value = "admin"
    },
    {
      name = "ingress.ingressClassName=nginx"
      value = "nginx"
    }
  ]
}

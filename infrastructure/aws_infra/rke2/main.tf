resource "null_resource" "write_kubeconfig" {
  triggers = {
    agent = var.rke2_server_id
    host  = var.rke2_server_publid_ip
  }

  depends_on = [
    var.rke2_server_id
  ]

  connection {
    host  = self.triggers.host
    user  = "ubuntu"
    agent = true
  }

  provisioner "local-exec" {
    command = <<EOF
      ssh-keygen -R ${var.rke2_server_publid_ip} >/dev/null 2>&1
      until rsync -e "ssh -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" --rsync-path="sudo rsync" ubuntu@${var.rke2_server_publid_ip}:/etc/rancher/rke2/rke2.yaml rke2.yaml >/dev/null 2>&1; do echo Wait rke2.yaml generation && sleep 5; done \
      && chmod go-r rke2.yaml \
      && yq eval --inplace '.clusters[0].cluster.server = "https://${var.lb_dns_name}:6443"' rke2.yaml \
      && mv rke2.yaml CloudComp20-aws.rke2.yaml
    EOF
  }
}

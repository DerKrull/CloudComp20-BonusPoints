locals {
  record_name                = "rke2-master.${var.internal_dns}"
  count_server_nodes         = 2
  user                       = "ubuntu"
  ssh_authorized_keys_loaded = [for key in var.ssh_authorized_keys : startswith(key, "/") || startswith(key, "~") ? file(key) : key]
  ssh_authorized_key         = local.ssh_authorized_keys_loaded[0]
  ssh_authorized_keys        = slice(local.ssh_authorized_keys_loaded, 1, length(local.ssh_authorized_keys_loaded))
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical owner ID for Ubuntu AMIs
}

data "aws_iam_instance_profile" "lab_instance_profile" {
  name = "LabInstanceProfile"
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key"
  public_key = local.ssh_authorized_key
}

module "rke2_server_bootstrap" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  name          = "rke2-server-0"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  user_data_base64 = base64encode(templatefile("${path.module}/install_rke2_master.sh", {
    load_balancer_dns = var.lb_dns_name
    internal_dns      = var.internal_dns
    record_name       = local.record_name
    hosted_zone_id    = var.hosted_zone_id
    cert_manager      = templatefile("${path.module}/manifests/cert-manager.yaml.tpl", {})
    rancher = templatefile("${path.module}/manifests/rancher.yaml.tpl", {
      load_balancer_dns = var.lb_dns_name
    })
  }))
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name
  iam_instance_profile        = data.aws_iam_instance_profile.lab_instance_profile.name
  subnet_id                   = var.subnet_a_id
  vpc_security_group_ids      = [var.sg_for_ec2_id]
  root_block_device = {
    delete_on_termination = true
    size                  = 50
  }
  tags = {
    Name = "rke2-server-0"
  }
}

resource "aws_lb_target_group_attachment" "server-bootstrap-http" {
  target_group_arn = var.rancher_http_tg_arn
  target_id        = module.rke2_server_bootstrap.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "server-bootstrap-https" {
  target_group_arn = var.rancher_https_tg_arn
  target_id        = module.rke2_server_bootstrap.id
  port             = 443
}

resource "aws_lb_target_group_attachment" "server-bootstrap-6443" {
  target_group_arn = var.rancher_control_https_tg_arn
  target_id        = module.rke2_server_bootstrap.id
  port             = 6443
}

resource "null_resource" "wait_for_rke2" {
  triggers = {
    agent = module.rke2_server_bootstrap.id
    host  = module.rke2_server_bootstrap.public_ip
  }

  connection {
    host    = self.triggers.host
    user    = local.user
    agent   = true
    timeout = "3m"
  }

  provisioner "remote-exec" {
    on_failure = continue
    inline = [
      "test \"$(sudo systemctl is-active rke2-server.service)\" = active"
    ]
  }
}

module "rke2_server" {
  source = "terraform-aws-modules/ec2-instance/aws"

  depends_on = [module.rke2_server_bootstrap, null_resource.wait_for_rke2]

  count = local.count_server_nodes

  name          = "rke2-server-${count.index + 1}"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  user_data_base64 = base64encode(templatefile("${path.module}/install_rke2_node.sh", {
    rke2_master_dns   = local.record_name
    load_balancer_dns = var.lb_dns_name
    internal_dns      = var.internal_dns
  }))
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key.key_name
  iam_instance_profile        = data.aws_iam_instance_profile.lab_instance_profile.name
  subnet_id                   = count.index == 0 ? var.subnet_a_id : var.subnet_b_id
  vpc_security_group_ids      = [var.sg_for_ec2_id]
  root_block_device = {
    delete_on_termination = true
    size                  = 50
  }
  tags = {
    Name = "rke2-server-${count.index + 1}"
  }
}

resource "aws_lb_target_group_attachment" "server-http" {
  count            = local.count_server_nodes
  target_group_arn = var.rancher_http_tg_arn
  target_id        = module.rke2_server[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "server-https" {
  count            = local.count_server_nodes
  target_group_arn = var.rancher_https_tg_arn
  target_id        = module.rke2_server[count.index].id
  port             = 443
}

resource "aws_lb_target_group_attachment" "server-6443" {
  count            = local.count_server_nodes
  target_group_arn = var.rancher_control_https_tg_arn
  target_id        = module.rke2_server[count.index].id
  port             = 6443
}

resource "aws_launch_template" "rke2_agent_templ" {
  name_prefix   = "rke2-agent-templ"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  user_data = base64encode(templatefile("${path.module}/install_rke2_agent.sh", {
    rke2_master_dns   = local.record_name
    load_balancer_dns = var.lb_dns_name
    internal_dns      = var.internal_dns
  }))
  key_name      = aws_key_pair.ec2_key.key_name
  ebs_optimized = true

  iam_instance_profile {
    arn = data.aws_iam_instance_profile.lab_instance_profile.arn
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_for_ec2_id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "rke2-agent" # Name for the EC2 instances
    }
  }
}

resource "aws_autoscaling_group" "rke2_node_asg" {
  desired_capacity = 3
  max_size         = 6
  min_size         = 0

  depends_on = [module.rke2_server_bootstrap, null_resource.wait_for_rke2]

  target_group_arns = [
    var.rancher_https_tg_arn,
    var.rancher_http_tg_arn
  ]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    var.subnet_a_id, var.subnet_b_id
  ]

  launch_template {
    id      = aws_launch_template.rke2_agent_templ.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }
}

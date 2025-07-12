locals {
  record_name = "rke2-master.${var.internal_dns}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]  # Canonical owner ID for Ubuntu AMIs
}

data "aws_iam_instance_profile" "lab_instance_profile" {
  name = "LabInstanceProfile"
}

resource "aws_key_pair" "ec2_key" {
  key_name = "ec2-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkyJS4CHgvAplYdW1vv3GJwotClk6Sujq1J/PPdXDTX felix@LAPTOP-VE0IUQ7K"
}

data "template_file" "install_script_master" {
  template = "${file("${path.module}/install_rancher_master.sh")}"
  vars = {
    load_balancer_dns = var.lb_dns_name
    internal_dns = var.internal_dns
    record_name = local.record_name
    hosted_zone_id = var.hosted_zone_id
  }
}

# ASG with Launch template
resource "aws_launch_template" "rancher-master-templ" {
  name_prefix   = "rancher-master-templ"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  user_data     = base64encode(data.template_file.install_script_master.rendered)
  key_name = aws_key_pair.ec2_key.key_name
  
  iam_instance_profile {
    arn = data.aws_iam_instance_profile.lab_instance_profile.arn
  }
  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_id
    security_groups             = [var.sg_for_ec2_id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "rancher-instance" # Name for the EC2 instances
    }
  }
}

resource "aws_autoscaling_group" "rancher_master_asg" {
  # no of instances
  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  # Connect to the target group
  target_group_arns = [
    var.rancher_tcp_443_tg_arn, 
    var.rancher_tcp_80_tg_arn, 
    var.rancher_master_tg_arn#
  ]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    var.subnet_id
  ]

  launch_template {
    id      = aws_launch_template.rancher-master-templ.id
    version = "$Latest"
  }
}

data "template_file" "install_script" {
  template = "${file("${path.module}/install_rancher_node.sh")}"
  vars = {
    rke2_master_dns = local.record_name
    load_balancer_dns = var.lb_dns_name
    internal_dns = var.internal_dns
  }
}

resource "aws_launch_template" "rancher-node-templ" {
  name_prefix   = "rancher-node-templ"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  user_data     = base64encode(data.template_file.install_script.rendered)
  key_name = aws_key_pair.ec2_key.key_name
  
  iam_instance_profile {
    arn = data.aws_iam_instance_profile.lab_instance_profile.arn
  }
  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.subnet_id
    security_groups             = [var.sg_for_ec2_id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "rancher-node" # Name for the EC2 instances
    }
  }
}

resource "aws_autoscaling_group" "rancher_node_asg" {
  # no of instances
  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  # Connect to the target group
  target_group_arns = [var.rancher_tcp_443_tg_arn, var.rancher_tcp_80_tg_arn]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    var.subnet_id
  ]

  launch_template {
    id      = aws_launch_template.rancher-node-templ.id
    version = "$Latest"
  }
}
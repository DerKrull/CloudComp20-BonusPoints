data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon official AMI account
}

resource "aws_key_pair" "ec2_key" {
  key_name = "ec2-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkyJS4CHgvAplYdW1vv3GJwotClk6Sujq1J/PPdXDTX felix@LAPTOP-VE0IUQ7K"
}

# ASG with Launch template
resource "aws_launch_template" "rancher-master-templ" {
  name_prefix   = "rancher-master-templ"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  user_data     = filebase64("./${path.module}/install_rancher_master.sh")
  key_name = aws_key_pair.ec2_key.key_name

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.private_subnet_1a_id
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
  target_group_arns = [var.alb_tg_arn]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    var.private_subnet_1a_id
  ]

  launch_template {
    id      = aws_launch_template.rancher-master-templ.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "rancher-worker-templ" {
  name_prefix   = "rancher-worker-templ"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t2.micro"
  user_data     = filebase64("./${path.module}/install_rancher_worker.sh")
  key_name = aws_key_pair.ec2_key.key_name

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.private_subnet_1a_id
    security_groups             = [var.sg_for_ec2_id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "rancher-worker" # Name for the EC2 instances
    }
  }
}

resource "aws_autoscaling_group" "rancher_worker_asg" {
  # no of instances
  desired_capacity = 4
  max_size         = 4
  min_size         = 2

  # Connect to the target group
  target_group_arns = [var.alb_tg_arn]

  vpc_zone_identifier = [ # Creating EC2 instances in private subnet
    var.private_subnet_1a_id
  ]

  launch_template {
    id      = aws_launch_template.rancher-worker-templ.id
    version = "$Latest"
  }
}
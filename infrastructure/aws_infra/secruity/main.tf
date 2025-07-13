resource "aws_security_group" "sg_for_elb" {
  name   = "sg_for_elb"
  vpc_id = var.vpc_id
  
  ingress {
    description      = "Allow http request from anywhere"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    description      = "Allow https request from anywhere"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow rke connections from internal"
    protocol = "tcp"
    from_port = 9432
    to_port = 9432
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "Kubernetes API"
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
    cidr_blocks = ["0.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/8"]
  }

}

resource "aws_security_group" "sg_for_ec2" {
  name   = "sg_for_ec2"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow http request from Load Balancer"
    protocol        = "tcp"
    from_port       = 80 # range of
    to_port         = 80 # port numbers
    #security_groups = [aws_security_group.sg_for_elb.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow https from Load balancer"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    #security_groups = [aws_security_group.sg_for_elb.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow rke connections"
    protocol = "tcp"
    from_port = 9432
    to_port = 9432
    #security_groups = [aws_security_group.sg_for_elb.id]
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "Kubernetes API"
    protocol = "tcp"
    from_port = 6443
    to_port = 6443
    #security_groups = [aws_security_group.sg_for_elb.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # or restrict to ALB subnet
  }

  ingress {
    description = "Allow ssh connections"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
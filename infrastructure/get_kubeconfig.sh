#!/bin/bash

aws s3 cp s3://cloudcomp20-terraform-state-bucket/rke2.yaml rke2-aws.yaml

load_balancer_dns=$(cat ./aws_infra/lb_dns_name.out)

sed -i "s/127.0.0.1/$load_balancer_dns/g" rke2-aws.yaml

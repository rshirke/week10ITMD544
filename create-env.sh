#!/bin/bash

aws elb create-load-balancer --load-balancer-name itmo544rshirke --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-d1bd94b5 --security-groups sg-dd9a4fa4

#3: launch configuration in auto scaling group
aws autoscaling create-launch-configuration --launch-configuration-name itmo544rshirkeconfig --image-id ami-06b94666 --security-group sg-dd9a4fa4 --key-name week3key --instance-type t2.micro --user-data file://installenv.sh
#TO GET THE KEY PAIR NAME TYPE aws ec2 describe-key-pairs: to get the security group type: aws ec2 describe-security_groups
#4: creating autoscaling
aws autoscaling create-auto-scaling-group --auto-scaling-group-name server-scalegroup --launch-configuration itmo544rshirkeconfig --availability-zone us-west-2b --load-balancer-name itmo544rshirke --max-size 5 --min-size 2 --desired-capacity 3



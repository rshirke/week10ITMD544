#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    echo "the syntax should be ./create-env.sh <<ami-id>> <<key-name>> <<security-group>> <<launch-configuration>> <<desired count of instances>> "
    exit 0
else
echo "the parameters are perfect and continuing to execute the script !"
fi

ami=$1
key_name=$2
security_group=$3
launch_configuration=$4
count=$5

if [ "$count" =~ ^-?[0-9]+$ ]; then 
echo "please enter positive integer as count"
exit 0
fi

aws elb create-load-balancer --load-balancer-name itmo544rshirke --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --subnets subnet-d1bd94b5 --security-groups $security_group

#3: launch configuration in auto scaling group
aws autoscaling create-launch-configuration --launch-configuration-name $launch_configuration --image-id $ami --security-group $security_group --key-name $key_name --instance-type t2.micro --user-data file://installenv.sh
#TO GET THE KEY PAIR NAME TYPE aws ec2 describe-key-pairs: to get the security group type: aws ec2 describe-security_groups
#4: creating autoscaling
aws autoscaling create-auto-scaling-group --auto-scaling-group-name server-scalegroup --launch-configuration $launch_configuration --availability-zone us-west-2b --load-balancer-name itmo544rshirke --max-size 5 --min-size 2 --desired-capacity $count



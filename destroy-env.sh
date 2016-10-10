
character_count=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[].AutoScalingGroupName'|wc -m`
count=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[].AutoScalingGroupName'|xargs -n1|wc -l`

echo "AutoScaling Groups are as follows...."

if [[ $character_count == 0 ]]
then
echo " No Autoscaling Groups found "
else
echo "$count Autoscaling groups present"
for (( i=0;i<$count;i++ ))
do

auto_scaling_group=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].AutoScalingGroupName'|xargs`
instances=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Instances[].InstanceId'|xargs`
instances_count=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Instances[].InstanceId'|xargs -n1|wc -l`
instance_char_count=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Instances[].InstanceId'|wc -m`


aws autoscaling update-auto-scaling-group --auto-scaling-group-name $auto_scaling_group --min-size 0
aws autoscaling detach-instances --instance-ids $instances --auto-scaling-group-name $auto_scaling_group --should-decrement-desired-capacity
inst_cnt=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Instances[].LifecycleState'|xargs -n1|wc -l`

for (( j=0;j<$inst_cnt;j++ ))
do

state=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Instances['$j'].LifecycleState'`

while [ $state != "None" ]
do
sleep 3
state=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Instances['$j'].LifecycleState'`
done
done



echo "Deleting Auto Scaling group $auto_scaling_group"

aws autoscaling delete-auto-scaling-group --auto-scaling-group-name $auto_scaling_group
if [ $? -eq 0 ]
then
sleep 7
delete_status=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Status'`
echo "Auto Sacling group state is $delete_status"
 while [ "$delete_status" != "None" ]
do
echo "Waiting for the autoscaling group to be deleted ...."
delete_status=`aws autoscaling describe-auto-scaling-groups --query 'AutoScalingGroups[0].Status'`
sleep 1
done


echo "Auto Scaling Group $auto_scaling_group is deleted successfully "
else
echo "Error deleting Auto Scaling Group $auto_scaling_group ...Exiting execution"
exit 0
fi 
done
fi

echo "launch configuration getting deleted"

configuration_count=`aws autoscaling describe-launch-configurations --query 'LaunchConfigurations[].LaunchConfigurationName'|wc -m`
if [ $configuration_count -ne 0 ]
then

for i in `aws autoscaling describe-launch-configurations --query 'LaunchConfigurations[].LaunchConfigurationName'|xargs`
do
echo $i
aws autoscaling delete-launch-configuration --launch-configuration-name $i
if [ $? -eq 0 ]
then
echo " Launch configuration $i deleted"
else
echo "Error deleting Launch configuration $i... Exiting execution"
exit 0
fi
done
else
echo "No Launch configuration found"
fi


character_count=`aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName"|wc -m`
load_balancer_count=`aws elb describe-load-balancers --query "LoadBalancerDescriptions[].LoadBalancerName"|xargs -n1|wc -l`

if [ $character_count -ne 0 ]
then

for (( i=0;i<$load_balancer_count;i++ ))
do
lb_name=`aws elb describe-load-balancers --query 'LoadBalancerDescriptions[0].LoadBalancerName'`
inst_name=`aws elb describe-load-balancers --query 'LoadBalancerDescriptions[0].Instances[].InstanceId'`
inst_count=`aws elb describe-load-balancers --query 'LoadBalancerDescriptions[0].Instances[].InstanceId'|xargs -n1|wc -l`

inst_char_count=`aws elb describe-load-balancers --query 'LoadBalancerDescriptions[0].Instances[].InstanceId'|wc -m`

if [ $inst_char_count -ne 0 ]
then
        echo "load balancer name: $lb_name"
        echo "instances attached : $inst_name"
        echo "Deregistering instances attached to $lb_name" 
echo
        aws elb deregister-instances-from-load-balancer --load-balancer-name $lb_name --instances $inst_name

        for (( j=0;j<$inst_count;j++ ))
        do
        state=`aws elb describe-instance-health --load-balancer-name $lb_name --query 'InstanceStates['$j'].State'`
        state=`aws elb describe-instance-health --load-balancer-name $lb_name --query 'InstanceStates['$j'].State'`
        echo "$inst_name : $state"
        while [ $state != "None" ]
       do
        echo "current state : $state"
        sleep 3
        state=`aws elb describe-instance-health --load-balancer-name $lb_name --query 'InstanceStates['$j'].State'`
        done
done
else
echo "No instances for load balancer $lb_name"
fi


        aws elb delete-load-balancer --load-balancer-name $lb_name
        if [ $? -eq 0 ]
then  
echo " $lb_name deleted successfully"
        echo
else
echo "Error deleting load balancer $lb_name"
fi

done
else
echo "No load balancer found"
fi

echo "Instance getting deleted"


instance_ids=`aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId'|xargs`
aws ec2 terminate-instances --instance-ids $instance_ids




echo "The Script is completed successfully"




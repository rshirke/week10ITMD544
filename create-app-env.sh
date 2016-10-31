aws rds create-db-instance --db-instance-identifier hirke13 --allocated-storage 20 --db-instance-class db.m1.small --engine mysql --vpc-security-group-ids sg-1682e96f --master-username rshirke --master-user-password rshirke123

status=`aws rds describe-db-instances --query "DBInstances[].DBInstanceStatus"`

while [ $status != "available" ]
do
status=`aws rds describe-db-instances --query "DBInstances[].DBInstanceStatus"`
echo
echo "please wait..the database is getting created and the current state is $status"
echo
sleep 15
done
echo
echo "Database is created successfully"

endpoint_addr=`aws rds describe-db-instances --query "DBInstances[].Endpoint.Address"`

echo "The End Point address : $endpoint_addr with Username : rshirke password: rshirke123 "

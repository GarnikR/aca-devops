#!/bin/bash
cd terraform
echo "step_1"
terraform output | grep EIP | awk -F'"' '/"/ {print $2}' >> ../ansible/inventory
echo "step_2"
rds_address=$(terraform output | grep RDS_IP | awk -F'"' '/"/ {print $2}')
echo "step_3"
terraform output | grep RDS_IP | awk -F'"' '/"/ {print $2}' >> ./testoutput

echo "step_4"
ansible-playbook ../ansible/book1.yaml -i ../ansible/inventory -e mysql_host=$rds_address --ssh-common-args='-o StrictHostKeyChecking=no'


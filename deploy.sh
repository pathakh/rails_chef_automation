#!/bin/bash

# Usage: ./deploy.sh [host] [rolename]


host=$1 # ip of the node
role=$2 # check roles directory
ssh_key=$3

knife solo bootstrap ubuntu@$host -i ~/.ssh/$ssh_key -r "role["$role"]"

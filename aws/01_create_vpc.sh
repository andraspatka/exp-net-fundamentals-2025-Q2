#!/bin/bash

set -ex

vpc_id=$(aws ec2 create-vpc --cidr-block "10.200.123.0/26" --instance-tenancy "default" --tag-specifications '{"ResourceType":"vpc","Tags":[{"Key":"Name","Value":"networking-bootcamp-vpc"}]}' | jq -r '.Vpc.VpcId')
aws ec2 modify-vpc-attribute --vpc-id ${vpc_id} --enable-dns-hostnames '{"Value":true}' 
aws ec2 describe-vpcs --vpc-ids ${vpc_id}

pub_subn_id=$(aws ec2 create-subnet --vpc-id ${vpc_id} --cidr-block "10.200.123.0/28" --availability-zone "eu-central-1a" --tag-specifications '{"ResourceType":"subnet","Tags":[{"Key":"Name","Value":"networking-bootcamp-subnet-public1-eu-central-1a"}]}' | jq -r '.Subnet.SubnetId')

priv_subn_id=$(aws ec2 create-subnet --vpc-id ${vpc_id} --cidr-block "10.200.123.32/28" --availability-zone "eu-central-1a" --tag-specifications '{"ResourceType":"subnet","Tags":[{"Key":"Name","Value":"networking-bootcamp-subnet-private1-eu-central-1a"}]}' | jq -r '.Subnet.SubnetId')

igw_id=$(aws ec2 create-internet-gateway --tag-specifications '{"ResourceType":"internet-gateway","Tags":[{"Key":"Name","Value":"networking-bootcamp-igw"}]}' | jq -r '.InternetGateway.InternetGatewayId')

aws ec2 attach-internet-gateway --internet-gateway-id ${igw_id} --vpc-id ${vpc_id} 

rtb_pub_id=$(aws ec2 create-route-table --vpc-id ${vpc_id} --tag-specifications '{"ResourceType":"route-table","Tags":[{"Key":"Name","Value":"networking-bootcamp-rtb-public"}]}' | jq -r '.RouteTable.RouteTableId')

aws ec2 create-route --route-table-id ${rtb_pub_id} --destination-cidr-block "0.0.0.0/0" --gateway-id ${igw_id} 
aws ec2 associate-route-table --route-table-id ${rtb_pub_id} --subnet-id ${pub_subn_id}

rtb_priv_id=$(aws ec2 create-route-table --vpc-id ${vpc_id} --tag-specifications '{"ResourceType":"route-table","Tags":[{"Key":"Name","Value":"networking-bootcamp-rtb-private1-eu-central-1a"}]}' | jq -r '.RouteTable.RouteTableId')
aws ec2 associate-route-table --route-table-id ${rtb_priv_id} --subnet-id ${priv_subn_id}
aws ec2 describe-route-tables --route-table-ids ${rtb_priv_id}

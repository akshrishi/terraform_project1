provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZ4EQZBY5F4GBO672"
  secret_key = "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"
}
#######################################################
#Creating Production VPC with CIDR: 10.0.0.0/16
resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16" 
    tags = {
        Name = "production VPC"
    }
}
output "vpcid" {
  value = aws_vpc.vpc.id
}
#######################################################
#Creating Public Subnet with CIDR: 10.0.0.0/24
resource "aws_subnet" "production_public_subnet" {
  vpc_id                  = "vpc-09a11e37628f4d0d6"
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name        = "production-public-subnet-1b"
  }
}
output "public_subnetid" {
  value = aws_subnet.production_public_subnet.id
}
#######################################################
#Creating Private Subnet with CIDR: 10.0.1.0/24
resource "aws_subnet" "prodution_private_subnet" {
  vpc_id                  = "vpc-09a11e37628f4d0d6"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    Name        = "production-private-subnet-1b"
  }
}
output "private_subnetid" {
  value = aws_subnet.prodution_private_subnet.id
}
#Creating IGW and attaching for Production VPC 
resource "aws_internet_gateway" "prod_igw" {
    vpc_id = "vpc-09a11e37628f4d0d6"
    tags = {
        Name = "prod-igw"
    }
}
output "internet_gateway_id" {
  value = aws_internet_gateway.prod_igw.id
}
#Adding Route table and IGW
resource "aws_route_table" "prod_public_rt" {
    vpc_id = "vpc-09a11e37628f4d0d6"  
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = "igw-02ae4c3a37d827d4f" 
    }
    tags = {
        Name = "prod-public-rt"
    }
}
output "Prodution_Public_RT_id" {
  value = aws_route_table.prod_public_rt.id
}#Adding public subnet to public route table
resource "aws_route_table_association" "prod-public-routetable"{
    subnet_id = "subnet-0b18cc79dd51881e2"
    route_table_id = "rtb-05afade5ebf5f4199"
}
#Creating an EIP
resource "aws_eip" "production_nat_eip" {
  vpc = true
  tags = {
      Name = "production_nat_eip"
  }
}
output "production_nat_eip" {
  value = aws_eip.production_nat_eip.id
}
#Creating NatGateway for Production VPC
resource "aws_nat_gateway" "production_natgateway"{
   allocation_id= "eipalloc-0a6bcd03fd9405857"
   subnet_id = "subnet-0ee717f3baf7946fa"
    tags = {
      Name = "Production Natgateway"
          }
}
output "production_natgateway_id" {
  value = aws_nat_gateway.production_natgateway.id
}
#Adding Route table and NatGateway
resource "aws_route_table" "prod_private_rt" {
    vpc_id = "vpc-09a11e37628f4d0d6"  
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = "nat-0c32b939aae3ea4ee" 
    }
    tags = {
        Name = "prod-private-rt"
    }
}
output "Prodution_Private_RT_id" {
  value = aws_route_table.prod_private_rt.id
}
#Adding private subnet to private route table
resource "aws_route_table_association" "prod-private-routetable"{
    subnet_id = "subnet-0ee717f3baf7946fa"
    route_table_id = "rtb-030aec60691310ff4"
}
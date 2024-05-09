provider "aws" {
region = "us-east-1"
}

module "custom-deploy" {
    source = "./modules/custom-deploy"
    ami = "ami-051f8a213df8bc089"
    instance_type = "t2.micro"
    vpc_block    = "10.1.0.0/16"
    subnet_block = "10.1.0.0/24"
}

output "ec2-instance-id" {
    value = module.custom-deploy.ec2-instance-id
}

output "ec2-instance-dns" {
    value = module.custom-deploy.ec2-instance-dns
}

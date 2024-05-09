output "ec2-instance-id" {
  value = aws_instance.test-terraform-ec2.id
}

output "ec2-instance-dns" {
  value = aws_instance.test-terraform-ec2.public_dns
}

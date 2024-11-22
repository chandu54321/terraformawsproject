output "aws_vpc" {
  value = aws_vpc.first.id
}
output "aws_instance" {
  value = "http://${aws_instance.firstins.public_ip}/browny"
}
output "aws_instance1" {
  value = "http://${aws_instance.secondins.public_ip}/repair"
}
output "aws_public1" {
  value = aws_subnet.public_subnet[0].id
}
output "aws_public2" {
  value = aws_subnet.public_subnet[1].id
}

# LOAD BALANCER OUTPUT
output "lboutoutput" {
  value = aws_lb.firstlb.dns_name
}
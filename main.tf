resource "aws_vpc" "first" {
  cidr_block         = var.aws_vpc.cidr_block
  enable_dns_support = var.aws_vpc.enable_dns_support
  tags               = var.aws_vpc.tags
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.subnet_public)
  vpc_id            = aws_vpc.first.id
  cidr_block        = var.subnet_public[count.index].cidr_block
  availability_zone = var.subnet_public[count.index].availability_zone
  tags              = var.subnet_public[count.index].tags
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.subnet_private)
  vpc_id            = aws_vpc.first.id
  cidr_block        = var.subnet_private[count.index].cidr_block
  availability_zone = var.subnet_private[count.index].availability_zone
  tags              = var.subnet_private[count.index].tags
}

resource "aws_internet_gateway" "forvpc" {
  vpc_id = aws_vpc.first.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.first.id
  tags = {
    name = "publicroutetable"
  }
}

resource "aws_route_table_association" "publicass" {
  count          = length(var.subnet_public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_route" "forpublicroute" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.forvpc.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.first.id
  tags = {
    name = "forprivate"
  }
}
resource "aws_route_table_association" "for_private" {
  count          = length(var.subnet_private)
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.first.id
  service_name      = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"


  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
POLICY

  tags = {
    Name = "S3GatewayEndpoint"
  }
}

resource "aws_s3_bucket" "firstbucket" {
  bucket = "mychandu-tf-test-bucket"
}

resource "aws_security_group" "sec1" {
  name        = var.aws_security_group.name
  vpc_id      = aws_vpc.first.id
  description = var.aws_security_group.description
}
resource "aws_vpc_security_group_ingress_rule" "forip" {
  count             = length(var.aws_security_group)
  security_group_id = aws_security_group.sec1.id
  cidr_ipv4         = var.aws_security_group.inbound_rules[count.index].source
  from_port         = var.aws_security_group.inbound_rules[count.index].port
  ip_protocol       = var.aws_security_group.inbound_rules[count.index].protocol
  to_port           = var.aws_security_group.inbound_rules[count.index].port
  description       = var.aws_security_group.inbound_rules[count.index].description
}
resource "aws_vpc_security_group_egress_rule" "web1" {
  security_group_id = aws_security_group.sec1.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "firstins" {
  ami                         = "ami-0dee22c13ea7a9a67"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sec1.id]
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  key_name                    = "id_rsapub"
  user_data                   = file("woody.sh")
  tags = {
    name = "first"
  }
}

resource "aws_instance" "secondins" {
  ami                         = "ami-0dee22c13ea7a9a67"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sec1.id]
  subnet_id                   = aws_subnet.public_subnet[1].id
  associate_public_ip_address = true
  key_name                    = "id_rsapub"
  user_data                   = file("repairs.sh")
  tags = {
    name = "second"
  }
}

resource "aws_lb" "firstlb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sec1.id]
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  tags = {
    "Name" = "firstlb"
  }
}
resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.first.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.firstins.id
  port             = 80
}
resource "aws_lb_target_group" "test2" {
  name     = "tf-example-lb-tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.first.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_lb_target_group_attachment" "tst1" {
  target_group_arn = aws_lb_target_group.test2.arn
  target_id        = aws_instance.secondins.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.firstlb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}
resource "aws_lb_listener_rule" "tenant1_rule" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
  condition {
    path_pattern {
      values = ["/woody/*"]
    }
  }
}
resource "aws_lb_listener" "front_end1" {
  load_balancer_arn = aws_lb.firstlb.arn
  port              = "81"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test2.arn
  }

}
resource "aws_lb_listener_rule" "tenant2_rule" {
  listener_arn = aws_lb_listener.front_end1.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test2.arn
  }
  condition {
    path_pattern {
      values = ["/repairs/*"]
    }
  }
}

resource "aws_sns_topic" "cpu_alerts" {
  name = "cpu-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cpu_alerts.arn
  protocol  = "email"
  endpoint  = "kasinenichandu@gmail.com" # Your email address
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name          = "High CPU Utilization Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = 300 # Check every 5 minutes
  statistic          = "Average"
  threshold          = 70.0
  alarm_description  = "This alarm triggers when CPU utilization exceeds 70%."

  dimensions = {
    InstanceId = aws_instance.firstins.id  # Replace with your actual EC2 instance ID
  }

  alarm_actions = [aws_sns_topic.cpu_alerts.arn]
}
variable "aws_vpc" {
  type = object({
    cidr_block         = string
    enable_dns_support = bool
    tags               = map(string)
  })
  default = {
    cidr_block         = "10.0.0.0/16"
    enable_dns_support = true
    tags = {
      "name" = "firstvpc"
    }
  }
}
variable "subnet_public" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    tags              = map(string)

  }))
  default = [{
    cidr_block        = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      name = "web-1"
    }
    }, {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "ap-south-1b"
    tags = {
      name = "web-2"
    }
  }]
}

variable "subnet_private" {
  type = list(object({
    cidr_block        = string
    availability_zone = string
    tags              = map(string)

  }))
  default = [{
    cidr_block        = "10.0.3.0/24"
    availability_zone = "ap-south-1a"
    tags = {
      name = "db-1"
    }
    }, {
    cidr_block        = "10.0.4.0/24"
    availability_zone = "ap-south-1b"
    tags = {
      name = "db-2"
    }
  }]
}

variable "aws_security_group" {
  type = object({
    name        = string
    description = string
    inbound_rules = list(object({
      protocol    = string
      port        = number
      source      = string
      description = string
    }))
  })
  default = {
    name        = "first"
    description = "this this is the first group"
    inbound_rules = [{
      port        = 22
      protocol    = "tcp"
      source      = "0.0.0.0/0"
      description = "open ssh"
      }, {
      port        = 80
      protocol    = "tcp"
      source      = "0.0.0.0/0"
      description = "open http"
      },
      {
        port        = 443
        protocol    = "tcp"
        source      = "0.0.0.0/0"
        description = "open https"
    }]
  }
}
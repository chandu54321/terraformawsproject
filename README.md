## Overview

This Terraform script is designed to set up an AWS infrastructure that includes a Virtual Private Cloud (VPC), subnets, security groups, EC2 instances, a load balancer, and monitoring with CloudWatch. Here's a summary of the key components:

### 1. **VPC and Subnets**
- **VPC Creation**: A Virtual Private Cloud (VPC) is created with specified CIDR block and DNS support.
- **Public and Private Subnets**: Two types of subnets are created:
  - **Public Subnets**: These subnets are associated with an internet gateway, allowing resources within them to communicate with the internet.
  - **Private Subnets**: These subnets do not have direct internet access.

### 2. **Internet Gateway**
- An **Internet Gateway** is created and attached to the VPC, enabling internet access for resources in the public subnets.

### 3. **Route Tables**
- **Public Route Table**: Configured to route traffic from the public subnets to the internet via the Internet Gateway.
- **Private Route Table**: Used for routing traffic from private subnets but does not allow direct internet access.

### 4. **S3 VPC Endpoint**
- A **VPC Endpoint** for Amazon S3 is created, allowing resources within the VPC to access S3 without going through the internet.

### 5. **S3 Bucket**
- An S3 bucket named "mychandu-tf-test-bucket" is created for storing data.

### 6. **Security Groups**
- A security group is defined to control inbound and outbound traffic for EC2 instances:
  - Inbound rules are defined based on specified sources and ports.
  - Outbound rules allow all traffic.

### 7. **EC2 Instances**
- Two EC2 instances are created in the public subnets:
  - The first instance runs a script called "woody.sh".
  - The second instance runs a script called "repairs.sh".
  
Both instances are of type `t2.micro` and have public IP addresses assigned.

### 8. **Load Balancer**
- An **Application Load Balancer (ALB)** is set up to distribute incoming traffic across the two EC2 instances.
- Two target groups are created for routing traffic based on specific path patterns:
  - One for paths matching `/woody/*`.
  - Another for paths matching `/repairs/*`.

### 9. **CloudWatch Monitoring**
- A CloudWatch metric alarm is configured to monitor CPU utilization on one of the EC2 instances:
  - If CPU utilization exceeds 70%, an alert is sent via email through an SNS topic named "cpu-alerts".

### 10. **SNS Topic**
- An SNS topic is created for sending alerts, and a subscription is set up to send notifications to a specified email address when alarms are triggered.


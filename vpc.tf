# Create VPC
# terraform aws create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = "${var.vpc-cidr}"
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "vpc"
  }
}

# Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "IGW"
  }
}

# Create NAT Public IP
resource "aws_eip" "nat-public-ip" {
  vpc = true
}


# Create Public NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-public-ip.id
  subnet_id     = aws_subnet.public-subnet1.id

  tags = {
    Name = "NAT GW-02"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet-gateway]
}


# Create Public Subnet1 
# terraform aws create subnet
resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public-subnet1-cidr}"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public Subnet1"
  }
}

# Create Public Subnet2 
# terraform aws create subnet
resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.public-subnet2-cidr}"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags      = {
    Name    = "Public Subnet2"
  }
}

# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags       = {
    Name     = "Public Route Table"
  }
}

# Associate Public Subnet1 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet1-route-table-association" {
  subnet_id           = aws_subnet.public-subnet1.id
  route_table_id      = aws_route_table.public-route-table.id
}

# Associate Public Subnet2 to "Public Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "public-subnet2-route-table-association" {
  subnet_id           = aws_subnet.public-subnet2.id
  route_table_id      = aws_route_table.public-route-table.id
}


# Create Private Subnet1 
# terraform aws create subnet
resource "aws_subnet" "private-subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.private-subnet1-cidr}"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags      = {
    Name    = "Private Subnet1"
  }
}

# Create Private Subnet2 
# terraform aws create subnet
resource "aws_subnet" "private-subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.private-subnet2-cidr}"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags      = {
    Name    = "Private Subnet2"
  }
}

# Create Route Table and Add Private Route
# terraform aws create route table
resource "aws_route_table" "private-route-table" {
  vpc_id       = aws_vpc.vpc.id

  tags       = {
    Name     = "Private Route Table"
  }
}

# Associate Private Subnet1 to "Private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet1-route-table-association" {
  subnet_id           = aws_subnet.private-subnet1.id
  route_table_id      = aws_route_table.private-route-table.id
}

# Associate Private Subnet2 to "Private Route Table"
# terraform aws associate subnet with route table
resource "aws_route_table_association" "private-subnet2-route-table-association" {
  subnet_id           = aws_subnet.private-subnet2.id
  route_table_id      = aws_route_table.private-route-table.id
}


# Public Security Group Creation
resource "aws_security_group" "public_security_group" {
  name   = "public_security_group"
  vpc_id = "${aws_vpc.vpc.id}"
}

# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access_public" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.public_security_group.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Ingress Security Port 80
resource "aws_security_group_rule" "http_inbound_access_public" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.public_security_group.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access_public" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.public_security_group.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Private Security Group Creation
resource "aws_security_group" "private_security_group" {
  name   = "private_security_group"
  vpc_id = "${aws_vpc.vpc.id}"
}

# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access_private" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.private_security_group.id}"
  type              = "ingress"
  cidr_blocks       = ["10.200.0.0/24"]
}

# Ingress Security Port 80
resource "aws_security_group_rule" "http_inbound_access_private" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.private_security_group.id}"
  type              = "ingress"
  cidr_blocks       = ["10.200.0.0/24"]
}

# Ingress Security Port for ICMP
resource "aws_security_group_rule" "icmp_inbound_access_private" {
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  security_group_id = "${aws_security_group.private_security_group.id}"
  type              = "ingress"
  cidr_blocks       = ["10.200.0.0/24"]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access_private" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.private_security_group.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Creating Public Load Balancer
resource "aws_lb" "public_load_balancer" {
  name               = "public-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_security_group.id]

  enable_deletion_protection = true

  subnet_mapping {
    subnet_id            = aws_subnet.public-subnet1.id
  }

  subnet_mapping {
    subnet_id            = aws_subnet.private-subnet1.id
  }

  tags = {
    Environment = "production"
  }
}

#Create a Public Listener on Port 80
resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create Public Target Group
resource "aws_lb_target_group" "public_target_group" {
  name     = "public-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

# Creating Private Load Balancer
resource "aws_lb" "private_load_balancer" {
  name               = "private-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_security_group.id]

  enable_deletion_protection = true

  subnet_mapping {
    subnet_id            = aws_subnet.public-subnet2.id
  }

  subnet_mapping {
    subnet_id            = aws_subnet.private-subnet2.id
  }

  tags = {
    Environment = "production"
  }
}

#Create a Private Listener on Port 80
resource "aws_lb_listener" "private_listener" {
  load_balancer_arn = aws_lb.private_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create Private Target Group
resource "aws_lb_target_group" "private_target_group" {
  name     = "private-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

# Create Public Launch Configuration 
resource "aws_launch_configuration" "public_launch_configuration" {
  name = "public_launch_configuration"
  image_id = "ami-0de8fac4ababecf19"
  security_groups = [aws_security_group.public_security_group.id]
  instance_type = "t2.micro"
  associate_public_ip_address = true
}

# Create Public Auto Scaling Group 
resource "aws_autoscaling_group" "public_autoscaling_group" {
  name                      = "public_autoscaling_group"
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.public_launch_configuration.id}"
  vpc_zone_identifier       = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
}

# Create Simple Scaling Up Policy for Public Auto Scaling Group
resource "aws_autoscaling_policy" "public_scaleup_policy" {
  name                   = "public_scaleup_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.public_autoscaling_group.name
}

# Create Simple Scaling Down Policy for Public Auto Scaling Group
resource "aws_autoscaling_policy" "public_scaledown_policy" {
  name                   = "public_scaledown_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.public_autoscaling_group.name
}

# Create Private Launch Configuration 
resource "aws_launch_configuration" "private_launch_configuration" {
  name = "private_launch_configuration"
  image_id = "ami-087c7312cd2b30666"
  security_groups = [aws_security_group.private_security_group.id]
  instance_type = "t2.micro"
}

# Create Private Auto Scaling Group 
resource "aws_autoscaling_group" "private_autoscaling_group" {
  name                      = "private_autoscaling_group"
  launch_configuration      = "${aws_launch_configuration.private_launch_configuration.id}"
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]
}

# Create Simple Scaling Up Policy for Private Auto Scaling Group
resource "aws_autoscaling_policy" "private_scaleup_policy" {
  name                   = "private_scaleup_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.private_autoscaling_group.name
}

# Create Simple Scaling Down Policy for Private Auto Scaling Group
resource "aws_autoscaling_policy" "private_scaledown_policy" {
  name                   = "private_scaledown_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.private_autoscaling_group.name
}
provider "aws" {
  region     = "us-west-2"
}

variable "vpc_id" {
  description = "ID of VPC for Security Group"
  default     = "vpc-898473e2"
}

resource "aws_security_group" "lb_security_group" {
  tags {
    Name = "web-server-lb"
    env  = "demo"
  }

  name        = "web-server-lb"
  description = "ELB for web servers"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "demo_elb" {
  name               = "demo"
  security_groups    = ["${aws_security_group.lb_security_group.id}"]
  subnets            = ["subnet-8e8473e5","subnet-888473e3"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    target              = "HTTP:80/"
    interval            = 10
    timeout             = 5
  }

  connection_draining         = true
  connection_draining_timeout = 300

  tags {
    Name = "web server demo"
    env  = "demo"
  }
}

resource "aws_launch_configuration" "demo_lc" {
  name          = "demo_lc"
  image_id      = "ami-a44a41dd"
  instance_type = "t2.micro"

  user_data     = <<EOF
#!/bin/bash
/sbin/service httpd start
EOF

  security_groups = ["${aws_security_group.web_server_security_group.id}"]
  key_name      = "yubikey"
}

resource "aws_autoscaling_group" "web_servers_ag" {
  vpc_zone_identifier       = ["subnet-a67170fe", "subnet-35eb4b7c"]
  name                      = "web_servers"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.demo_lc.name}"
  load_balancers            = ["${aws_elb.demo_elb.id}"]

  tag {
    key                 = "Name"
    value               = "WebServer"
    propagate_at_launch = true
  }

  tag {
    key                 = "env"
    value               = "demo"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "web_server_security_group" {
  tags {
    Name = "web-servers"
    env  = "demo"
  }

  name        = "web-servers"
  description = "SG for web servers"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

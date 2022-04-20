#----------------------------------------------------------
# My Terraform
#
# Remote State on S3
#
# Made by Dmitry Yemelin
#----------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webserver.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform with Remote State"  >  /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
EOF
  tags = {
    Name = "${var.env}-WebServer"
  }
}
*/

resource "aws_security_group" "webserver" {
  name   = "WebServer Security Group"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.env}-web-server-sg"
    Owner = "dmitry yemelin"
  }
}




/*
terraform {
  backend "s3" {
    bucket = "dmitry-yemelin-project-terraform-state" // Bucket where to SAVE Terraform State
    key    = "dev/servers/terraform.tfstate"          // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                              // Region where bycket created
  }
}

#====================================================================


data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "dmitry-yemelin-project-terraform-state" // Bucket from where to GET Terraform State
    key    = "dev/network/terraform.tfstate"          // Object name in the bucket to GET Terraform state
    region = "us-east-1"                              // Region where bycket created
  }
}


output "network_details" {
  value = data.terraform_remote_state.network
}
*/




#===============================================================
https://github.com/nelg/terraform-aws-acmdemo



resource "aws_alb" "mylb" {
  # Normal ALB content, options removed for BLOG
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.myapp.id]
}

# Basic https lisener to demo HTTPS certiciate
resource "aws_alb_listener" "mylb_https" {
  load_balancer_arn = aws_alb.mylb.arn
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn
  port              = "443"
  protocol          = "HTTPS"
  # Default action, and other paramters removed for BLOG
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<html><body><h1>Hello World!</h1><p>This would usually be to a target group of web servers.. but this is just a demo to returning a fixed response\n\n</p></body></html>"
      status_code  = "200"
    }
  }
}

# Always good practice to redirect http to https
resource "aws_alb_listener" "mylb_http" {
  load_balancer_arn = aws_alb.mylb.arn
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

# Open Security Group for demo
resource "aws_security_group" "myapp" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#=================================================================

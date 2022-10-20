#----------------------------------------------------------
# My Terraform
#
# Remote State on S3
#
# Made by Dmitry Yemelin
#----------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.15.1"
    }
  }

  backend "s3" {
    bucket = "quest-terraform-node-ecs"
    key = "dev"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}


/*

resource "aws_ecs_cluster" "quest_ecs_cluster" {
  name = "quest-ecs-cluster"
}

resource "aws_autoscaling_group" "quest_ecs_cluster_instances" {
    name = "quest-ecs-cluster-instances"
    min_size = 1
    max_size = 2
    launch_configuration -
    "${aws_launch_configuration.quest_ecs_instance.name}"
}

#the launch config defines what runs on each EC2 instance
resource "aws_launch_configuration" "quest_ecs_instance" {
  name_prefix = "quest-ecs-instance-"
  instance_type = "t2.micro"

#this is Amazon ECS AMI, which has an ECS Agent installed
#that lets it talk to the ECS cluster
  image_id = "ami-a98cb2c3"
}

resource "aws_ecs_task_definition" "quest" {
  family = "quest-ecs-task-definition"
  container_definitions = jsonencode([
    {
      name = "quest"
      image = "temp1ar/myquest:latest"
      cpu = 1024
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort = 3000
        }
      ]
    }
    ])
}


resource "aws_ecs_service" "quest_ecs_service" {
    family = "quest-ecs-task-definition"
    cluster = "${aws_ecs_cluster.quest_ecs_cluster.id}"
    task_definition = "${aws_ecs_task_definition.quest.arn}"
    desired_count = 1
}






data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

*/
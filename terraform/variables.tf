variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI for us-east-1"
  default     = "ami-0c101f26f147fa7fd"
}

variable "key_name" {
  description = "Your EC2 key pair name for SSH access"
  default = "k8s-in-one-shot"
}

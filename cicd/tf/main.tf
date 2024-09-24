variable "TIMESTAMP" {
  type        = string
  default     = null
}

variable "instance_names" {
  type = list(string)
  default = ["k8s-master", "k8s-worker-1", "k8s-worker-2"]
}

provider "aws" {
  region = "ap-south-1"
}

# Create the EC2 instances
resource "aws_instance" "k8s_instances" {
  count = length(var.instance_names)

  launch_template {
    id = "lt-06adb93a7ee898ce7"
    version = "$Latest"
  }

  tags = {
    Name = var.instance_names[count.index]
  }
}


# Create a dynamic inventory file
resource "local_file" "ansible_inventory" {
  filename = "/tmp/inventory-${var.TIMESTAMP}"
  content = <<-EOF
  [all:vars]
  ansible_connection=ssh
  ansible_user=ubuntu
  ansible_ssh_private_key_file=~/capstone-g4.pem

  [ec2_instances]
  ${aws_instance.k8s_instances[0].private_ip}
  ${aws_instance.k8s_instances[1].private_ip}
  ${aws_instance.k8s_instances[2].private_ip}

  [kubernetes_control_plane]
  ${aws_instance.k8s_instances[0].private_ip}

  [kubernetes_workers]
  ${aws_instance.k8s_instances[1].private_ip}
  ${aws_instance.k8s_instances[2].private_ip}
  EOF
}

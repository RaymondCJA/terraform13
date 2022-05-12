locals {
  ami = "ami-0a8b4cd432b1c3063"
  login = local.github_pat != "" ? "echo ${local.github_pat} | docker login ghcr.io -u raymondcja --password-stdin" : ""
}

resource "aws_instance" "instance" {
  ami           = local.ami
  root_block_device  {
    volume_size = 40
}
  iam_instance_profile = "LabInstanceProfile"
  instance_type = local.instance_type
  user_data = <<-EOT
#!/bin/bash
yum update -y
yum install -y docker
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
${local.login}
docker run ${local.environment} ${local.ports} ${local.image}
  EOT
  security_groups = local.security_groups

  tags = local.tags
}
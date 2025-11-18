locals {
  ami = data.aws_ami.amazon_linux_2023.id

  userdata = templatefile("${path.module}/scripts/user-data.sh", {
    ssh_port = var.ssh_port
  })
}

### --------------------------------------------------
### EC2 Instance
### --------------------------------------------------
resource "aws_instance" "main" {
  ami                    = local.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = concat([aws_security_group.main.id], var.additional_sgs)
  subnet_id              = var.subnet_id
  user_data              = local.userdata
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.prefix}-${var.instance_name}"
  }

  depends_on = [aws_security_group.main]
}

resource "aws_eip" "main" {
  count  = var.allocate_eip ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.prefix}-${var.instance_name}-eip"
  }
}

resource "aws_eip_association" "main" {
  count         = var.allocate_eip ? 1 : 0
  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main[0].id
}

### --------------------------------------------------
### Security Group
### --------------------------------------------------
resource "aws_security_group" "main" {
  name        = "${var.prefix}-${var.instance_name}"
  description = "Security group for the EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = each.value
      to_port     = each.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-${var.instance_name}"
  }
}

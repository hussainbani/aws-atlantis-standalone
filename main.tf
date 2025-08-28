resource "aws_network_interface" "interface" {
  subnet_id = var.subnet_id
  tags      = local.tags

  # If the above security group is empty, we avoid including it in the list of
  # network interface security groups.
  security_groups = concat(
    var.additional_security_groups,
    [module.atlantis-sg.security_group_id],
  )
}

resource "aws_instance" "instance" {
  ami                  = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.profile.name
  tags                 = merge(local.tags, var.additional_tags)
  availability_zone    = var.availability_zone
  ebs_optimized        = true

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.encrypted_volume
    tags        = merge(local.tags, var.additional_tags)
  }

  network_interface {
    network_interface_id = aws_network_interface.interface.id
    device_index         = 0
  }

  key_name  = var.key_name
  user_data = data.cloudinit_config.config.rendered

  # Ignore changes to these parameters. If these are changed, instances
  # must be manually tainted before they will be replaced.
  lifecycle {
    ignore_changes = [
      ami,
      key_name,
      user_data,
    ]
  }
}

# Create requested volumes
resource "aws_ebs_volume" "vol" {
  for_each          = local.volumes
  type              = each.value.type
  availability_zone = var.availability_zone
  size              = each.value.size
  encrypted         = var.encrypted_volume
  tags = merge(local.tags, {
    Name         = "${var.name}-${each.value.lv_name}"
    dlm_snapshot = each.value.dlm_snapshot
  }, var.additional_tags)
}

# Attach volumes to instance
resource "aws_volume_attachment" "vol" {
  for_each = local.volumes

  device_name = each.key
  instance_id = aws_instance.instance.id
  volume_id   = aws_ebs_volume.vol[each.key].id
  lifecycle {
    ignore_changes = [
      device_name,
    ]
  }
}

resource "aws_eip" "eip" {
  count    = (((var.eip == null) || (var.eip == false)) ? 0 : 1)
  instance = aws_instance.instance.id
}

# DNS

resource "aws_route53_record" "int" {
  count    = var.create_dns_records ? 1 : 0
  provider = aws.r53
  zone_id  = var.r53_zone_id
  name     = "${var.name}.int.${var.domain}"
  type     = "A"
  ttl      = "300"
  records  = aws_network_interface.interface.private_ips
}
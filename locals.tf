locals {
  location = replace(var.region, "-", "")

  tags = {
    Name       = var.name
    managed_by = "terraform"
  }

  # Prepare a suitable map for for_each, used by aws_ebs_volume and
  # aws_volume_attachment.
  volumes = {
    for volume in var.volumes :
    volume.device => {
      lv_name      = volume.lv_name
      size         = volume.size
      dlm_snapshot = volume.dlm_snapshot
      type         = lookup(volume, "type", "gp3")
    }
  }

  # Prepare a cut down volumes map suitable for the EC2 user-data.
  user_data_volumes = [
    for volume in var.volumes : {
      device      = volume.device
      lv_name     = volume.lv_name
      mount_point = volume.mount_point
    }
  ]

  atlantis_domain = "${var.name}.${var.domain}"
}
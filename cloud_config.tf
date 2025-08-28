data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud_config.tpl", {
      atlantis_domain = local.atlantis_domain
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/bootstrap.tpl", {
      # System variables
      atlantis_version  = var.atlantis_version
      conftest_version  = var.conftest_version
      git_lfs_version   = var.git_lfs_version
      terraform_version = var.terraform_version
      go_version        = var.go_version

      # AWS credentials (as base64)
      aws_credentials_base64 = var.aws_credentials_base64

      # GitHub configuration
      github_app_private_key     = var.github_app_private_key
      repo_allowlist             = var.repo_allowlist
      atlantis_domain            = local.atlantis_domain
      atlantis_gh_webhook_secret = var.atlantis_gh_webhook_secret
      atlantis_gh_app_id         = var.atlantis_gh_app_id
      atlantis_username          = var.atlantis_username
      atlantis_password          = var.atlantis_password
    })
  }
}
# These providers must be passed explicitly from the calling module using the
# providers {} block.
# https://www.terraform.io/docs/configuration/modules.html

provider "aws" {
}

# Provider for managing R53 records
provider "aws" {
  alias = "r53"
}

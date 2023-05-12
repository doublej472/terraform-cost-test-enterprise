provider "aws" {
  region  = var.region
  profile = var.AWS_PROFILE
  default_tags {
    tags = {
      Creator     = "Jonathan Frederick"
      CreatedWith = "Terraform"
    }
  }
}

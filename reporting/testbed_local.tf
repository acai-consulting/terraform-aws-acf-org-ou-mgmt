# ---------------------------------------------------------------------------------------------------------------------
# ¦ PROVIDER
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region  = "eu-central-1"
  profile = "acai_testbed"
  assume_role {
    role_arn = "arn:aws:iam::471112796356:role/OrganizationAccountAccessRole" # ACAI AWS Testbed Org-Mgmt Account
  }
}

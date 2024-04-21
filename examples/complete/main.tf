# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = []
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ CREATE PROVISIONER
# ---------------------------------------------------------------------------------------------------------------------
module "create_provisioner" {
  source = "../../cicd-principals/terraform"

  iam_role_settings = {
    name             = "cicd_provisioner"
    aws_trustee_arns = ["arn:aws:iam::471112796356:root"]
  }
  providers = {
    aws = aws.org_mgmt
  }
}

provider "aws" {
  region = "eu-central-1"
  alias  = "cicd_provisioner"
  assume_role {
    role_arn = module.create_provisioner.iam_role_arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_organizations_policy" "scp_example" {
  name = "test_scp"
  type = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
    ]
  })
  provider = aws.org_mgmt
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ LOCALS
# ---------------------------------------------------------------------------------------------------------------------
locals {
  workload_units = [
    {
      name = "CICD"
    },
    {
      name    = "Prod"
      scp_ids = [aws_organizations_policy.scp_example.id]
    },
    {
      name = "NonProd"
    }
  ]

  # OU-Names are case-sensitive!!!
  organizational_units = {
    level1_units : [
      # Artificial Org Structure
      {
        name : "level1_unit1",
        scp_ids = [aws_organizations_policy.scp_example.id]
        level2_units : [
          {
            name : "level1_unit1__level2_unit1"
          },
          {
            name : "level1_unit1__level2_unit2",
            level3_units = [
              {
                name : "level1_unit1__level2_unit2__level3_unit1",
                tags : {
                  "key1" : "value 1",
                  "key2" : "value 2"
                }
              }
            ]
          }
        ]
      },
      {
        name : "level1_unit2",
        level2_units : [
          {
            name : "level1_unit2__level2_unit1"
          },
          {
            name : "level1_unit2__level2_unit2"
          },
          {
            name : "level1_unit2__level2_unit3"
          }
        ]
      },

      # Sample "real-life" Org Structure
      {
        name = "CoreAccounts",
        level2_units = [
          {
            name = "Management"
          },
          {
            name = "Security"
          },
          {
            name = "Connectivity"
          }
        ]
      },
      {
        name = "SandboxAccounts",
      },
      {
        name = "WorkloadAccounts",
        level2_units = [
          {
            name         = "BusinessUnit_1"
            level3_units = local.workload_units
          },
          {
            name         = "BusinessUnit_2"
            level3_units = local.workload_units
          },
          {
            name         = "BusinessUnit_3"
            level3_units = local.workload_units
          }
        ]
      }
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ¦ MODULE
# ---------------------------------------------------------------------------------------------------------------------
module "example_complete" {
  source = "../../"

  organizational_units = local.organizational_units
  providers = {
    aws = aws.cicd_provisioner
  }
}

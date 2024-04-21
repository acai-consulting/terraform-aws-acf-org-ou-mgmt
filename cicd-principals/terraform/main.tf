# ---------------------------------------------------------------------------------------------------------------------
# ¦ VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.10"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.0"
      configuration_aliases = []
    }
  }
}


resource "aws_iam_role" "cicd_principal" {
  name                 = var.iam_role_settings.name
  path                 = var.iam_role_settings.path
  permissions_boundary = var.iam_role_settings.permissions_boundary_arn
  description          = "IAM Role used to provision the OrganizationStructure"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  tags                 = var.resource_tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.iam_role_settings.aws_trustee_arns
    }
  }
}

resource "aws_iam_role_policy" "OrganizationStructure" {
  name   = "OrganizationStructure"
  role   = aws_iam_role.cicd_principal.id
  policy = data.aws_iam_policy_document.org_structure_policy.json
}

#tfsec:ignore:AVD-AWS-0057
data "aws_iam_policy_document" "org_structure_policy" {
  #checkov:skip=CKV_AWS_111 
  #checkov:skip=CKV_AWS_356 
  statement {
    effect = "Allow"
    actions = [
      "organizations:DescribeOrganization",
      "organizations:ListRoots",
      "organizations:ListParents",
      "organizations:ListOrganizationalUnitsForParent",
      "organizations:ListAccounts",
      "organizations:ListAccountsForParent",
      "organizations:ListAWSServiceAccessForOrganization",
      "organizations:DescribeOrganizationalUnit",
      "organizations:CreateOrganizationalUnit",
      "organizations:UpdateOrganizationalUnit",
      "organizations:DeleteOrganizationalUnit",
      "organizations:AttachPolicy",
      "organizations:DetachPolicy",
      "organizations:DescribePolicy",
      "organizations:ListTargetsForPolicy",
      "organizations:ListTagsForResource",
      "organizations:TagResource",
    ]
    resources = ["*"]
  }
}

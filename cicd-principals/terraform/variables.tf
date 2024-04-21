variable "iam_role_settings" {
  description = "Settings for IAM Roles."
  type = object({
    name                     = string
    path                     = optional(string, "/")
    permissions_boundary_arn = optional(string)
    aws_trustee_arns         = list(string)
  })

  validation {
    condition     = var.iam_role_settings.path == null ? true : can(regex("^/([^/]+(/[^/]+)*/?)?$", var.iam_role_settings.path))
    error_message = "Path value must start with '/' and can optionally end with '/', without containing consecutive '/' characters."
  }

  validation {
    condition     = var.iam_role_settings.permissions_boundary_arn == null ? true : can(regex("^arn:aws:iam::[0-9]{12}:policy/.+$", var.iam_role_settings.permissions_boundary_arn))
    error_message = "Permissions boundary ARN must be a valid IAM policy ARN, starting with 'arn:aws:iam::', followed by a 12-digit AWS account number, and the policy name."
  }
}

variable "resource_tags" {
  description = "A map of tags to assign to the resources in this module."
  type        = map(string)
  default     = {}
}

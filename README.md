# terraform-aws-acf-org-ou-mgmt Terraform module

<!-- LOGO -->
<a href="https://acai.gmbh">    
  <img src="https://github.com/acai-consulting/acai.public/raw/main/logo/logo_github_readme.png" alt="acai logo" title="ACAI" align="right" height="75" />
</a>

<!-- SHIELDS -->
[![Maintained by acai.gmbh][acai-shield]][acai-url]
![module-version-shield]
![terraform-version-shield]
![trivy-shield]
![checkov-shield]
[![Latest Release][release-shield]][release-url]

<!-- BEGIN_ACAI_DOCS -->
[Terraform][terraform-url] module to deploy the AWS Organization Unit hierarchy

This module is designed to:

- Provision the AWS Organization Unit (OU) Structure based on a given HCL map.
- Optionally assign existing SCPs to OUs.
- Optionally assign tags to OUs.

![architecture]

### OU-Structure

Will provision the AWS Organization Unit (OU) structure based on a given HCL map.

Define OU-Structure:

``` hcl
locals {
  # OU-Names are case-sensitive!!!
  organizational_units = {
    level1_units : [
      # Artificial Org Structure
      {
        name : "level1_unit1",
        scp_ids = ["p-yxodpfe7"]
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
      }
    ]
  }
}
```

Provide the above specifications to the ACF Module:

```hcl
module "aws_organization_units" {
  source  = "app.terraform.io/acai-consulting/org-ou-mgmt/aws"
  version = "~> 1.0"

  organizational_units = local.organizational_units
  providers = {
    aws = aws.org_mgmt
  }
}
```
<!-- END_ACAI_DOCS -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_organizations_organizational_unit.level_1_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_2_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_3_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_4_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_5_ous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_policy_attachment.level_1_ous_scp_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.level_2_ous_scp_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.level_3_ous_scp_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.level_4_ous_scp_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.level_5_ous_scp_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organizational_units"></a> [organizational\_units](#input\_organizational\_units) | The organization with the tree of organizational units and their tags. OU-Names are case-sensitive!!! | <pre>object({<br>    level1_units = optional(list(object({<br>      name    = string,<br>      scp_ids = optional(list(string), [])<br>      tags    = optional(map(string), {}),<br>      level2_units = optional(list(object({<br>        name    = string,<br>        scp_ids = optional(list(string), [])<br>        tags    = optional(map(string), {}),<br>        level3_units = optional(list(object({<br>          name    = string,<br>          scp_ids = optional(list(string), [])<br>          tags    = optional(map(string), {}),<br>          level4_units = optional(list(object({<br>            name    = string,<br>            scp_ids = optional(list(string), [])<br>            tags    = optional(map(string), {}),<br>            level5_units = optional(list(object({<br>              name    = string,<br>              scp_ids = optional(list(string), [])<br>              tags    = optional(map(string), {}),<br>            })), [])<br>          })), [])<br>        })), [])<br>      })), [])<br>    })), [])<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_level_1_ous_details"></a> [level\_1\_ous\_details](#output\_level\_1\_ous\_details) | Details of Level 1 Organizational Units with OU path as key. |
| <a name="output_level_2_ous_details"></a> [level\_2\_ous\_details](#output\_level\_2\_ous\_details) | Details of Level 2 Organizational Units. |
| <a name="output_level_3_ous_details"></a> [level\_3\_ous\_details](#output\_level\_3\_ous\_details) | Details of Level 3 Organizational Units. |
| <a name="output_level_4_ous_details"></a> [level\_4\_ous\_details](#output\_level\_4\_ous\_details) | Details of Level 4 Organizational Units. |
| <a name="output_level_5_ous_details"></a> [level\_5\_ous\_details](#output\_level\_5\_ous\_details) | Details of Level 5 Organizational Units. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | The ID of the AWS Organization. |
| <a name="output_organizational_units_paths_ids"></a> [organizational\_units\_paths\_ids](#output\_organizational\_units\_paths\_ids) | Map of full OU-Path and OU-ID. |
| <a name="output_ou_scp_assignment"></a> [ou\_scp\_assignment](#output\_ou\_scp\_assignment) | SCP assignments. |
| <a name="output_ou_transformed"></a> [ou\_transformed](#output\_ou\_transformed) | List of transformed OUs. |
| <a name="output_root_ou_id"></a> [root\_ou\_id](#output\_root\_ou\_id) | The ID of the root organizational unit. |
<!-- END_TF_DOCS -->

<!-- AUTHORS -->
## Authors

This module is maintained by [ACAI GmbH][acai-url].

<!-- LICENSE -->
## License

See [LICENSE][license-url] for full details.

<!-- MARKDOWN LINKS & IMAGES -->
[acai-shield]: https://img.shields.io/badge/maintained_by-acai.gmbh-CB224B?style=flat
[acai-url]: https://acai.gmbh
[module-version-shield]: https://img.shields.io/badge/module_version-1.1.1-CB224B?style=flat
[terraform-version-shield]: https://img.shields.io/badge/tf-%3E%3D1.3.10-blue.svg?style=flat&color=blueviolet
[trivy-shield]: https://img.shields.io/badge/trivy-passed-green
[checkov-shield]: https://img.shields.io/badge/checkov-passed-green
[release-shield]: https://img.shields.io/github/v/release/acai-consulting/terraform-aws-acf-org-ou-mgmt?style=flat&color=success
[release-url]: https://github.com/acai-consulting/terraform-aws-acf-org-ou-mgmt/releases
[license-url]: https://github.com/acai-consulting/terraform-aws-acf-org-ou-mgmt/tree/main/LICENSE.md
[terraform-url]: https://www.terraform.io
[aws-url]: https://aws.amazon.com
[architecture]: ./docs/terraform-aws-acf-org-ou-mgmt.png

# ---------------------------------------------------------------------------------------------------------------------
# ¦ OU-Names are case-sensitive!!!
# ---------------------------------------------------------------------------------------------------------------------
variable "organizational_units" {
  description = "The organization with the tree of organizational units and their tags. OU-Names are case-sensitive!!!"
  type = object({
    level1_units = optional(list(object({
      name    = string,
      scp_ids = optional(list(string), [])
      tags    = optional(map(string), {}),
      level2_units = optional(list(object({
        name    = string,
        scp_ids = optional(list(string), [])
        tags    = optional(map(string), {}),
        level3_units = optional(list(object({
          name    = string,
          scp_ids = optional(list(string), [])
          tags    = optional(map(string), {}),
          level4_units = optional(list(object({
            name    = string,
            scp_ids = optional(list(string), [])
            tags    = optional(map(string), {}),
            level5_units = optional(list(object({
              name    = string,
              scp_ids = optional(list(string), [])
              tags    = optional(map(string), {}),
            })), [])
          })), [])
        })), [])
      })), [])
    })), [])
  })
  default = null
}

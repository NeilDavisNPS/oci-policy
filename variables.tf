
variable "tenancy_ocid" {
 type = string
 description = "ocid of the tenancy"
}

variable "defaults" {
  description = "Vaules for creating and assigning one or more policies to a compartment"
  type = object({

    policy_compartment = string
    parent_compartment = string
    policies_per_compartment = map(object({

      statements  = list(string)
      description = string
    }))
  })

  default = null
}


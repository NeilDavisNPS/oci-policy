terraform {

  required_version = ">= 0.14.5"
  required_providers {
    oci = {
      source                = "hashicorp/oci"
      version               = ">= 4.58.0"
      configuration_aliases = [oci.src]
    }
  }
}



# ---------------------- end of providers --------------------

locals {

  policy_compartment       = lookup(var.defaults, "policy_compartment")
  parent_compartment       = lookup(var.defaults, "parent_compartment")
  policies_per_compartment = lookup(var.defaults, "policies_per_compartment")
  tenancy_ocid             = var.tenancy_ocid

}

# ----------------------- end of configuration -----------------

data "oci_identity_compartments" "this" {
  for_each       = toset([local.parent_compartment])
  compartment_id = local.tenancy_ocid
  name           = each.key
}

data "oci_identity_compartments" "_children" {
  for_each = toset([local.policy_compartment])
  # Attach compartment to root if no parent listed
  compartment_id = try(data.oci_identity_compartments.this[local.parent_compartment].compartments[0].id, var.tenancy_ocid)
  name           = each.key
}


resource "oci_identity_policy" "this" {


  for_each = local.policies_per_compartment
  #Required
  compartment_id = try(data.oci_identity_compartments._children[local.policy_compartment].compartments[0].id, data.oci_identity_compartments.this[local.parent_compartment].compartments[0].id )
  description    = each.value.description
  name           = each.key
  statements     = each.value.statements

  #Optional
  freeform_tags = try(each.value.freeform_tags, null)
  #version_date = var.policy_version_date
}

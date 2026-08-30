# ------------------------------------------------------------------------------
# Published contract of the networking context.
#
# `networks` has the same shape for every cloud. Provider-specific handles that
# have no counterpart elsewhere (Azure's resource group, GCP's secondary IP
# ranges) are published separately rather than forced into that shape.
# ------------------------------------------------------------------------------

locals {
  networks = merge(
    local.aws_enabled ? { aws = {
      id              = module.aws[0].vpc_id
      cidr            = module.aws[0].vpc_cidr
      private_subnets = module.aws[0].private_subnet_ids
      public_subnets  = module.aws[0].public_subnet_ids
    } } : {},
    local.azure_enabled ? { azure = {
      id              = module.azure[0].vnet_id
      cidr            = var.address_space.azure
      private_subnets = [module.azure[0].aks_subnet_id]
      public_subnets  = [module.azure[0].private_endpoints_subnet_id]
    } } : {},
    local.gcp_enabled ? { gcp = {
      id              = module.gcp[0].network_id
      cidr            = var.address_space.gcp
      private_subnets = [module.gcp[0].subnet_id]
      public_subnets  = [module.gcp[0].subnet_id]
    } } : {},
  )
}

output "networks" {
  description = "Uniform per-cloud fabric: id, cidr and subnet ids."
  value       = local.networks
}

output "azure_resource_group_name" {
  description = "Resource group every Azure resource in this platform is placed into. Empty when azure is not in scope."
  value       = local.azure_enabled ? module.azure[0].resource_group_name : ""
}

output "gcp_cluster_ranges" {
  description = "Secondary IP ranges GKE requires for pods and services. GKE addresses them by name, and there is no equivalent on the other providers."
  value = local.gcp_enabled ? {
    network        = module.gcp[0].network_name
    subnetwork     = module.gcp[0].subnet_name
    pods_range     = module.gcp[0].pods_range_name
    services_range = module.gcp[0].services_range_name
  } : null
}

output "egress_addresses" {
  description = "Stable egress addresses, for allow-listing at partner firewalls. Evidence for CIS network exposure controls."
  value = merge(
    local.aws_enabled ? { aws = module.aws[0].nat_gateway_ip } : {},
    local.azure_enabled ? { azure = module.azure[0].firewall_public_ip } : {},
  )
}

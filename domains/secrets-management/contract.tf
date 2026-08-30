# ------------------------------------------------------------------------------
# Bounded context: secrets-management
#
# Owns the in-cluster secret store: Vault in HA mode with Raft storage.
#
# Distinct from the cloud secret store owned by access-control. Different
# threat model, different failure domain, and deliberately not interchangeable.
# ------------------------------------------------------------------------------

resource "terraform_data" "guards" {
  lifecycle {
    precondition {
      condition     = var.environment != "prd" || !var.tls_disable
      error_message = "tls_disable must be false in prd. An unencrypted Vault listener fails ISO 27001 A.8.24 and SOC 2 CC6.7 regardless of what the mesh provides."
    }
    precondition {
      condition     = var.environment != "prd" || var.replicas >= 3
      error_message = "replicas must be at least 3 in prd. Raft cannot tolerate a node failure with fewer voters, and losing quorum seals the vault."
    }
  }
}

module "kubernetes" {
  source = "./kubernetes"

  namespace     = var.namespace
  replicas      = var.replicas
  storage_size  = var.storage_size
  storage_class = var.storage_class
  tls_disable   = var.tls_disable

  depends_on = [terraform_data.guards]
}

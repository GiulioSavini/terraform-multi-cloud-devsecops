# Bounded context: networking

Owns the fabric the clusters are placed into: address space, subnets, and the
egress path.

## Invariants

1. **Address ranges do not overlap.** Clusters peer across them; overlapping
   ranges blackhole traffic at runtime with no build error.
2. **Every cloud in scope has placement.**
3. **Azure's resource group is owned here.** Every Azure resource in the
   platform is placed into it, so no downstream context can claim it.

## Contract

`networks` is uniform. Two outputs deliberately are not: `gcp_cluster_ranges`
(GKE addresses its secondary pod and service ranges by name, and no other
provider has an equivalent) and `azure_resource_group_name`. Forcing those into
the uniform shape would mean inventing fields that are null for two of three
clouds.

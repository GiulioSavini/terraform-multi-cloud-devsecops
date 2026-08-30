# Bounded context: cluster-platform

Owns the managed Kubernetes control planes and their node pools.

This is the seam of the platform. Everything below it is cloud infrastructure;
everything above it runs inside a cluster and consumes `clusters` without
knowing whether it is talking to EKS, AKS or GKE.

## Invariants

1. **The Kubernetes version is pinned, never latest.** An unpinned control
   plane upgrades underneath the workloads and silently invalidates whatever
   the last conformance run proved.
2. **`min >= 2` nodes.** A single node cannot drain for an upgrade without
   downtime.
3. **No public API server in production.** `endpoint_public_access` must be
   false in `prd`.
4. **GKE needs named secondary ranges.** They come from the networking
   contract; GKE cannot be created without them.

## Contract

`clusters` is marked sensitive because it carries CA certificates and
endpoints. `cluster_names` exists as the non-sensitive counterpart, so a name
can be printed in a plan or a log without tainting the whole output.

`aws_irsa` is deliberately AWS-shaped. IAM Roles for Service Accounts has no
counterpart on the other providers, and pretending otherwise would mean
publishing fields that are null two times out of three.

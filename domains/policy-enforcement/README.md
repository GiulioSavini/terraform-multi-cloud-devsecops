# Bounded context: policy-enforcement

Owns admission control inside the cluster: Gatekeeper and its constraints.

One adapter, `kubernetes/`, because the implementation is Kubernetes rather
than a cloud. The context spans every cluster the platform runs.

## Admission-time vs plan-time

This context enforces at **admission time**: what anyone applies to the cluster.
`compliance/policies` enforces at **plan time**: what Terraform is about to
create. Both exist because neither sees what the other sees.

## Invariants

1. **At least two replicas in production.** Gatekeeper sits on the admission
   path; a single replica is a single point of failure whose outage blocks
   every deployment in the cluster.

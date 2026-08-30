# observability / kubernetes adapter

**This is a private adapter of the `observability` bounded context. Do not source it
directly.**

It translates the `observability` contract into Kubernetes resources, and its interface
tracks the Kubernetes provider rather than the domain — it will change when the
provider does, without a major version bump, because nothing outside the
context is supposed to depend on it.

Consume [`domains/observability`](../) instead. `scripts/check-boundaries.sh` fails CI
if this directory is sourced from outside its own context.

If you need something this adapter exposes and the contract does not, add it to
the contract.

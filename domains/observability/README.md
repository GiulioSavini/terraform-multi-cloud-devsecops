# Bounded context: observability

Owns in-cluster metrics, dashboards and alerting: the Prometheus and Grafana
stack.

Cloud-native logging and threat detection belong to `domains/access-control`.
This context is only what runs inside the cluster.

## Invariants

1. **90 days of retention in production**, so capacity planning and incident
   review have a quarter of history.
2. **Storage class is explicit in production.** Falling back to the cluster
   default silently binds production metrics to whatever class the cluster
   happens to ship with.
3. **A 16-character minimum on the Grafana password.** Grafana is
   internet-adjacent through ingress and is routinely credential-stuffed.

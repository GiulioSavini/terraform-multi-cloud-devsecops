# Bounded context: traffic-ingress

Owns how external traffic reaches a workload: ingress controllers, load
balancer wiring, certificate issuance and external DNS.

## Invariants

1. **Ingress requires a cluster.** A cloud in scope without an entry in
   `cluster_names` fails at plan time.
2. **AWS requires IRSA.** The load balancer controller assumes a role through
   IRSA; without it the controller installs and then silently fails to
   provision anything.
3. **The ACME contact address is validated.** Let's Encrypt sends expiry
   warnings there, and an address nobody reads means certificates expire
   silently at 90 days.

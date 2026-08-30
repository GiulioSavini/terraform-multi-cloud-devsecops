package main

import data.lib
import rego.v1

# CLU-01 -- The Kubernetes API server is not reachable from the internet in
# production.
#
# A public API server is the single highest-value target in a cluster: it is
# authenticated, but it is also reachable by every credential-stuffing bot on
# the internet, and an RBAC mistake becomes remotely exploitable rather than
# internally exploitable.

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_eks_cluster"
	a := lib.after(r)
	is_production(a)
	a.vpc_config[_].endpoint_public_access == true
	msg := sprintf("CLU-01: %s exposes the EKS API server to the internet in production. Set endpoint_public_access = false (CIS Kubernetes 5.x, ISO 27001 A.8.20).", [r.address])
}

deny contains msg if {
	r := lib.changed[_]
	r.type == "azurerm_kubernetes_cluster"
	a := lib.after(r)
	is_production(a)
	a.private_cluster_enabled == false
	msg := sprintf("CLU-01: %s is a public AKS cluster in production. Set private_cluster_enabled = true.", [r.address])
}

# CLU-02 -- The control plane version is pinned.
#
# An unpinned control plane upgrades underneath the workloads and silently
# invalidates whatever the last conformance run proved.

deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_eks_cluster"
	not r.change.after.version
	msg := sprintf("CLU-02: %s does not pin a Kubernetes version. An unpinned control plane upgrades underneath the workloads.", [r.address])
}

deny contains msg if {
	r := lib.changed[_]
	r.type == "google_container_cluster"
	a := lib.after(r)
	a.min_master_version == null
	msg := sprintf("CLU-02: %s does not pin min_master_version.", [r.address])
}

# CLU-03 -- Control plane audit logging is enabled.
deny contains msg if {
	r := lib.changed[_]
	r.type == "aws_eks_cluster"
	a := lib.after(r)
	not "audit" in object.get(a, "enabled_cluster_log_types", [])
	msg := sprintf("CLU-03: %s does not enable the 'audit' control plane log type. Without it there is no record of who changed what in the cluster (ISO 27001 A.8.15, SOC 2 CC7.2).", [r.address])
}

is_production(a) if {
	object.get(a, "tags", {}).Environment == "prd"
}

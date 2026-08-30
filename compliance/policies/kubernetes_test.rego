package main

import rego.v1

plan(resources) := {"resource_changes": resources}

clu_findings contains m if {
	some m in deny
	startswith(m, "CLU-")
}

eks(env, public, version, logs) := {
	"address": "module.cluster_platform.module.aws[0].aws_eks_cluster.this",
	"type": "aws_eks_cluster",
	"change": {"actions": ["create"], "after": {
		"tags": {"Environment": env},
		"vpc_config": [{"endpoint_public_access": public}],
		"version": version,
		"enabled_cluster_log_types": logs,
	}},
}

all_logs := ["api", "audit", "authenticator", "controllerManager", "scheduler"]

test_private_pinned_audited_cluster_is_allowed if {
	count(clu_findings) == 0 with input as plan([eks("prd", false, "1.30", all_logs)])
}

test_public_api_server_in_production_is_denied if {
	count(clu_findings) == 1 with input as plan([eks("prd", true, "1.30", all_logs)])
}

test_public_api_server_in_dev_is_allowed if {
	count(clu_findings) == 0 with input as plan([eks("dev", true, "1.30", all_logs)])
}

test_unpinned_version_is_denied if {
	r := {
		"address": "module.cluster_platform.module.aws[0].aws_eks_cluster.this",
		"type": "aws_eks_cluster",
		"change": {"actions": ["create"], "after": {
			"tags": {"Environment": "dev"},
			"vpc_config": [{"endpoint_public_access": false}],
			"enabled_cluster_log_types": all_logs,
		}},
	}
	count(clu_findings) == 1 with input as plan([r])
}

test_missing_audit_log_type_is_denied if {
	count(clu_findings) == 1 with input as plan([eks("dev", false, "1.30", ["api", "scheduler"])])
}

test_public_aks_in_production_is_denied if {
	r := {
		"address": "module.cluster_platform.module.azure[0].azurerm_kubernetes_cluster.this",
		"type": "azurerm_kubernetes_cluster",
		"change": {"actions": ["create"], "after": {
			"tags": {"Environment": "prd"},
			"private_cluster_enabled": false,
		}},
	}
	count(clu_findings) == 1 with input as plan([r])
}

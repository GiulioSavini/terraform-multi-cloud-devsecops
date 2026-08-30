# ------------------------------------------------------------------------------
# Control catalog
#
# Maps each control this platform claims to the bounded context that implements
# it and the contract output that evidences it. The catalog is data; enforcement
# lives in compliance/policies (plan time), in the preconditions inside each
# context (plan time), and in domains/policy-enforcement (admission time).
# ------------------------------------------------------------------------------

locals {
  controls = {
    "NET-01" = {
      statement = "Cloud address ranges do not overlap and clusters run in private subnets."
      context   = "networking"
      evidence  = "networks"
      severity  = "high"
      frameworks = {
        cis      = "CIS 5.x Networking"
        iso27001 = "A.8.22 Segregation of networks"
        soc2     = "CC6.6 Boundary protection"
        nis2     = "Art. 21(2)(d)"
      }
    }

    "NET-02" = {
      statement = "Egress leaves through a known, stable address."
      context   = "networking"
      evidence  = "egress_addresses"
      severity  = "medium"
      frameworks = {
        cis      = "CIS 5.x"
        iso27001 = "A.8.20 Network security"
        soc2     = "CC6.6"
        nis2     = "Art. 21(2)(e)"
      }
    }

    "SEC-01" = {
      statement = "Cloud threat detection is enabled (GuardDuty, Security Hub, Config, SCC)."
      context   = "access-control"
      evidence  = "threat_detection"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 3.x / 4.x Logging and monitoring"
        iso27001 = "A.8.16 Monitoring activities"
        soc2     = "CC7.2 System monitoring"
        nis2     = "Art. 21(2)(b) Incident handling"
      }
    }

    "SEC-02" = {
      statement = "A WAF with a bounded rate limit fronts public endpoints."
      context   = "access-control"
      evidence  = "waf_rate_limit"
      severity  = "high"
      frameworks = {
        cis      = "CIS 5.x"
        iso27001 = "A.8.20 Network security, A.8.23 Web filtering"
        soc2     = "CC6.6"
        nis2     = "Art. 21(2)(e)"
      }
    }

    "CLU-01" = {
      statement = "The Kubernetes API server is not reachable from the internet in production."
      context   = "cluster-platform"
      evidence  = "endpoint_public_access"
      severity  = "critical"
      frameworks = {
        cis      = "CIS Kubernetes 5.x Managed services"
        iso27001 = "A.8.20 Network security"
        soc2     = "CC6.6"
        nis2     = "Art. 21(2)(i) Access control"
      }
    }

    "CLU-02" = {
      statement = "The control plane version is pinned, never tracking latest."
      context   = "cluster-platform"
      evidence  = "kubernetes_version"
      severity  = "high"
      frameworks = {
        cis      = "CIS Kubernetes 1.x"
        iso27001 = "A.8.8 Management of technical vulnerabilities"
        soc2     = "CC7.1 Change management"
        nis2     = "Art. 21(2)(e) Vulnerability handling"
      }
    }

    "CLU-03" = {
      statement = "Node pools can drain for an upgrade without downtime (minimum two nodes)."
      context   = "cluster-platform"
      evidence  = "clusters"
      severity  = "medium"
      frameworks = {
        cis      = "—"
        iso27001 = "A.8.14 Redundancy"
        soc2     = "A1.2 Availability"
        nis2     = "Art. 21(2)(c) Business continuity"
      }
    }

    "ING-01" = {
      statement = "External traffic terminates TLS with automatically renewed certificates."
      context   = "traffic-ingress"
      evidence  = "domain_name"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 4.x"
        iso27001 = "A.8.24 Use of cryptography"
        soc2     = "CC6.7 Transmission of data"
        nis2     = "Art. 21(2)(h) Cryptography"
      }
    }

    "POL-01" = {
      statement = "Admission control is enforced in-cluster and highly available."
      context   = "policy-enforcement"
      evidence  = "replicas"
      severity  = "critical"
      frameworks = {
        cis      = "CIS Kubernetes 5.2 Pod Security Standards"
        iso27001 = "A.8.9 Configuration management"
        soc2     = "CC7.1 Change management"
        nis2     = "Art. 21(2)(e)"
      }
    }

    "VLT-01" = {
      statement = "The in-cluster secret store terminates TLS and keeps Raft quorum."
      context   = "secrets-management"
      evidence  = "tls_enabled"
      severity  = "critical"
      frameworks = {
        cis      = "CIS 1.x"
        iso27001 = "A.8.24 Use of cryptography, A.5.17 Authentication information"
        soc2     = "CC6.1 Logical access"
        nis2     = "Art. 21(2)(h)"
      }
    }

    "MSH-01" = {
      statement = "Pod-to-pod traffic is mutually authenticated and encrypted."
      context   = "service-mesh"
      evidence  = "mtls_enabled"
      severity  = "high"
      frameworks = {
        cis      = "—"
        iso27001 = "A.8.24 Use of cryptography, A.8.22 Segregation of networks"
        soc2     = "CC6.7"
        nis2     = "Art. 21(2)(h) Cryptography"
      }
    }

    "OBS-01" = {
      statement = "In-cluster metrics are retained long enough for incident review."
      context   = "observability"
      evidence  = "retention_days"
      severity  = "high"
      frameworks = {
        cis      = "CIS 3.x Logging"
        iso27001 = "A.8.15 Logging, A.8.16 Monitoring activities"
        soc2     = "CC7.2 System monitoring"
        nis2     = "Art. 21(2)(b)"
      }
    }

    "TAG-01" = {
      statement = "Every cloud resource carries owner, cost centre and data classification."
      context   = "platform/tagging"
      evidence  = "mandatory_keys"
      severity  = "medium"
      frameworks = {
        cis      = "—"
        iso27001 = "A.5.9 Inventory of assets"
        soc2     = "CC3.2 Risk identification"
        nis2     = "Art. 21(2)(a) Risk analysis"
      }
    }
  }

  frameworks = ["cis", "iso27001", "soc2", "nis2"]
}

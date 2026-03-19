# -----------------------------------------------------------------------------
# Linkerd Service Mesh Module
# Linkerd CRDs, control plane, and viz extension with mTLS.
# Generates trust anchor and issuer certificates for identity.
# -----------------------------------------------------------------------------

# ─── Trust Anchor Certificate (Root CA) ──────────────────────
resource "tls_private_key" "trust_anchor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "trust_anchor" {
  private_key_pem       = tls_private_key.trust_anchor.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 87600 # 10 years

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  subject {
    common_name = "root.linkerd.cluster.local"
  }
}

# ─── Issuer Certificate ──────────────────────────────────────
resource "tls_private_key" "issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "issuer" {
  private_key_pem = tls_private_key.issuer.private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "issuer" {
  cert_request_pem      = tls_cert_request.issuer.cert_request_pem
  ca_private_key_pem    = tls_private_key.trust_anchor.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.trust_anchor.cert_pem
  validity_period_hours = 8760 # 1 year
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

# ─── Linkerd CRDs ────────────────────────────────────────────
resource "helm_release" "linkerd_crds" {
  name             = "linkerd-crds"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-crds"
  namespace        = "linkerd"
  create_namespace = true
  version          = "1.8.0"
  timeout          = 300
}

# ─── Linkerd Control Plane ───────────────────────────────────
resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-control-plane"
  namespace  = "linkerd"
  version    = "1.16.11"
  timeout    = 600

  # Identity Trust Anchor
  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.trust_anchor.cert_pem
  }

  # Identity Issuer
  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer.private_key_pem
  }

  # HA Configuration
  set {
    name  = "controllerReplicas"
    value = tostring(var.replicas)
  }

  # Proxy Resources
  set {
    name  = "proxy.resources.cpu.request"
    value = "100m"
  }

  set {
    name  = "proxy.resources.memory.request"
    value = "64Mi"
  }

  set {
    name  = "proxy.resources.cpu.limit"
    value = "1"
  }

  set {
    name  = "proxy.resources.memory.limit"
    value = "256Mi"
  }

  # Controller Resources
  set {
    name  = "destinationResources.cpu.request"
    value = "100m"
  }

  set {
    name  = "destinationResources.memory.request"
    value = "128Mi"
  }

  set {
    name  = "identityResources.cpu.request"
    value = "100m"
  }

  set {
    name  = "identityResources.memory.request"
    value = "128Mi"
  }

  set {
    name  = "proxyInjectorResources.cpu.request"
    value = "100m"
  }

  set {
    name  = "proxyInjectorResources.memory.request"
    value = "128Mi"
  }

  depends_on = [helm_release.linkerd_crds]
}

# ─── Linkerd Viz Extension ───────────────────────────────────
resource "helm_release" "linkerd_viz" {
  name             = "linkerd-viz"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-viz"
  namespace        = "linkerd-viz"
  create_namespace = true
  version          = "30.12.11"
  timeout          = 600

  set {
    name  = "dashboard.replicas"
    value = "1"
  }

  set {
    name  = "prometheus.enabled"
    value = tostring(var.enable_viz_prometheus)
  }

  set {
    name  = "grafana.enabled"
    value = "false"
  }

  depends_on = [helm_release.linkerd_control_plane]
}

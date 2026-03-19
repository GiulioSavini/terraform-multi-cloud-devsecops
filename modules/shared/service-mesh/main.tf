# Linkerd CRDs
resource "helm_release" "linkerd_crds" {
  name             = "linkerd-crds"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-crds"
  namespace        = "linkerd"
  create_namespace = true
  version          = "1.8.0"
}

# Linkerd Control Plane
resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-control-plane"
  namespace  = "linkerd"
  version    = "1.16.11"

  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.trust_anchor.cert_pem
  }
  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer.cert_pem
  }
  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer.private_key_pem
  }

  set {
    name  = "controllerReplicas"
    value = var.environment == "prd" ? "3" : "1"
  }

  depends_on = [helm_release.linkerd_crds]
}

# Linkerd Viz (dashboard)
resource "helm_release" "linkerd_viz" {
  name       = "linkerd-viz"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd-viz"
  namespace  = "linkerd-viz"
  create_namespace = true
  version    = "30.12.11"

  depends_on = [helm_release.linkerd_control_plane]
}

# Trust Anchor Certificate
resource "tls_private_key" "trust_anchor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "trust_anchor" {
  private_key_pem       = tls_private_key.trust_anchor.private_key_pem
  is_ca_certificate     = true
  validity_period_hours = 87600 # 10 years
  allowed_uses          = ["cert_signing", "crl_signing"]
  subject {
    common_name = "root.linkerd.cluster.local"
  }
}

# Issuer Certificate
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
  allowed_uses          = ["cert_signing", "crl_signing"]
}

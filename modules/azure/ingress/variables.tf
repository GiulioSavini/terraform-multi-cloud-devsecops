variable "domain_name" {
  description = "Base domain name for DNS records"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]+[a-z0-9]$", var.domain_name))
    error_message = "Must be a valid domain name."
  }
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt certificate notifications"
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.letsencrypt_email))
    error_message = "Must be a valid email address."
  }
}

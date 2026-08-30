variable "landing_zone" {
  description = "Platform identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, stg, prd)."
  type        = string
}

variable "clouds" {
  description = "Clouds in scope."
  type        = list(string)
}

variable "networks" {
  description = "The `networks` output of the networking context."
  type        = any
}

variable "placement" {
  description = "Provider-specific placement."
  type = object({
    azure = optional(object({
      location            = string
      resource_group_name = string
    }))
    gcp = optional(object({ project_id = string }))
  })
  default = {}
}

variable "log_analytics_workspace_id" {
  description = "Azure workspace security diagnostics are sent to. Empty leaves diagnostics unrouted."
  type        = string
  default     = ""
}

variable "waf_rate_limit" {
  description = "Requests per five minutes per source IP before the WAF blocks. Too high is indistinguishable from no rate limit."
  type        = number
  default     = 2000

  validation {
    condition     = var.waf_rate_limit >= 100 && var.waf_rate_limit <= 20000000
    error_message = "waf_rate_limit must be between 100 and 20000000 (the AWS WAF bounds)."
  }
}

variable "tags" {
  description = "Tag set from platform/tagging."
  type        = map(string)
}

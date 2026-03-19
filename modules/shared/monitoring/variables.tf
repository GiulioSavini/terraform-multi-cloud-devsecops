variable "environment" { type = string }
variable "grafana_admin_password" { type = string; sensitive = true; default = "admin" }
variable "storage_class" { type = string; default = "gp2" }
variable "retention" { type = string; default = "15d" }

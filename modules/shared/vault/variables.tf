variable "environment" { type = string }
variable "replicas" { type = number; default = 3 }
variable "storage_size" { type = string; default = "10Gi" }

variable "k8s_agent_count" {
  default = 1
}

variable "k8s_agent_size" {
  default = "Standard_E2s_v3"
}

variable prefix {
  default = "DevOpsDemo"
}

variable location {
  default = "East US"
}

variable environment {
  default = "DEV"
}

variable "letsencrypt_email" {}

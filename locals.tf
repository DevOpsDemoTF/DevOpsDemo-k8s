locals {
  CName = "${var.prefix}${var.environment}Kubernetes"
  cname = lower("${var.prefix}${var.environment}kubernetes")
}
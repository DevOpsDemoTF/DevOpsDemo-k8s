locals {
  CName = "${var.prefix}${var.environment}"
  cname = lower("${var.prefix}${var.environment}")
}
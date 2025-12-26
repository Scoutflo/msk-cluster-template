################################################################################
# US West 2 Outputs
################################################################################

output "us_west_2_cluster_arn" {
  description = "ARN of the MSK cluster in US West 2"
  value       = module.msk_cluster_us_west_2.arn
}

output "us_west_2_bootstrap_brokers_tls" {
  description = "TLS bootstrap brokers for US West 2 cluster"
  value       = module.msk_cluster_us_west_2.bootstrap_brokers_tls
  sensitive   = true
}

output "us_west_2_bootstrap_brokers_sasl_iam" {
  description = "SASL IAM bootstrap brokers for US West 2 cluster"
  value       = module.msk_cluster_us_west_2.bootstrap_brokers_sasl_iam
  sensitive   = true
}

output "us_west_2_cluster_name" {
  description = "Name of the MSK cluster in US West 2"
  value       = module.msk_cluster_us_west_2.cluster_name
}

output "us_west_2_cluster_uuid" {
  description = "UUID of the MSK cluster in US West 2"
  value       = module.msk_cluster_us_west_2.cluster_uuid
}

################################################################################
# AP South 2 Outputs
################################################################################

output "ap_south_2_cluster_arn" {
  description = "ARN of the MSK cluster in AP South 2"
  value       = module.msk_cluster_ap_south_2.arn
}

output "ap_south_2_bootstrap_brokers_tls" {
  description = "TLS bootstrap brokers for AP South 2 cluster"
  value       = module.msk_cluster_ap_south_2.bootstrap_brokers_tls
  sensitive   = true
}

output "ap_south_2_bootstrap_brokers_sasl_iam" {
  description = "SASL IAM bootstrap brokers for AP South 2 cluster"
  value       = module.msk_cluster_ap_south_2.bootstrap_brokers_sasl_iam
  sensitive   = true
}

output "ap_south_2_cluster_name" {
  description = "Name of the MSK cluster in AP South 2"
  value       = module.msk_cluster_ap_south_2.cluster_name
}

output "ap_south_2_cluster_uuid" {
  description = "UUID of the MSK cluster in AP South 2"
  value       = module.msk_cluster_ap_south_2.cluster_uuid
}


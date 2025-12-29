################################################################################
# Monitoring and Alerts
# CloudWatch alarms, SNS notifications, KMS keys, and S3 logging
################################################################################

################################################################################
# CloudWatch Alarms for US West 2
################################################################################

resource "aws_cloudwatch_metric_alarm" "us_west_2_storage_high" {
  provider            = aws.us_west_2
  alarm_name          = "msk-us-west-2-storage-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "KafkaDataLogsDiskUsed"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "MSK cluster storage utilization is above 85%"
  alarm_actions       = [aws_sns_topic.msk_alerts.arn]

  dimensions = {
    ClusterName = module.msk_cluster_us_west_2.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "us_west_2_under_replicated" {
  provider            = aws.us_west_2
  alarm_name          = "msk-us-west-2-under-replicated-partitions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnderReplicatedPartitions"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "MSK cluster has under-replicated partitions"
  alarm_actions       = [aws_sns_topic.msk_alerts.arn]

  dimensions = {
    ClusterName = module.msk_cluster_us_west_2.cluster_name
  }
}

################################################################################
# CloudWatch Alarms for AP South 1
# COMMENTED OUT: Waiting for ec2:DescribeVpcs permission in ap-south-1 region
# Uncomment this section once permissions are added
################################################################################

# resource "aws_cloudwatch_metric_alarm" "ap_south_1_storage_high" {
#   provider            = aws.ap_south_1
#   alarm_name          = "msk-ap-south-1-storage-utilization-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "KafkaDataLogsDiskUsed"
#   namespace           = "AWS/Kafka"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 85
#   alarm_description   = "MSK cluster storage utilization is above 85%"
#   alarm_actions       = [aws_sns_topic.msk_alerts.arn]

#   dimensions = {
#     ClusterName = module.msk_cluster_ap_south_1.cluster_name
#   }
# }

# resource "aws_cloudwatch_metric_alarm" "ap_south_1_under_replicated" {
#   provider            = aws.ap_south_1
#   alarm_name          = "msk-ap-south-1-under-replicated-partitions"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "UnderReplicatedPartitions"
#   namespace           = "AWS/Kafka"
#   period              = 300
#   statistic           = "Sum"
#   threshold           = 0
#   alarm_description   = "MSK cluster has under-replicated partitions"
#   alarm_actions       = [aws_sns_topic.msk_alerts.arn]

#   dimensions = {
#     ClusterName = module.msk_cluster_ap_south_1.cluster_name
#   }
# }

################################################################################
# SNS Topic for Alerts
################################################################################

resource "aws_sns_topic" "msk_alerts" {
  provider = aws.us_west_2
  name     = "msk-cluster-alerts"
}

resource "aws_sns_topic_subscription" "msk_alerts_email" {
  provider  = aws.us_west_2
  topic_arn = aws_sns_topic.msk_alerts.arn
  protocol  = "email"
  endpoint  = "your-team@example.com"
}

################################################################################
# Customer-Managed KMS Key (Optional - replace AWS managed keys)
################################################################################

resource "aws_kms_key" "msk_us_west_2" {
  provider                = aws.us_west_2
  description             = "KMS key for MSK encryption in US West 2"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = {
    Name        = "msk-kms-key-us-west-2"
    Environment = "production"
  }
}

resource "aws_kms_alias" "msk_us_west_2" {
  provider      = aws.us_west_2
  name          = "alias/msk-us-west-2"
  target_key_id = aws_kms_key.msk_us_west_2.key_id
}

# COMMENTED OUT: Waiting for ec2:DescribeVpcs permission in ap-south-1 region
# resource "aws_kms_key" "msk_ap_south_1" {
#   provider                = aws.ap_south_1
#   description             = "KMS key for MSK encryption in AP South 1"
#   enable_key_rotation     = true
#   deletion_window_in_days = 30

#   tags = {
#     Name        = "msk-kms-key-ap-south-1"
#     Environment = "production"
#   }
# }

# resource "aws_kms_alias" "msk_ap_south_1" {
#   provider      = aws.ap_south_1
#   name          = "alias/msk-ap-south-1"
#   target_key_id = aws_kms_key.msk_ap_south_1.key_id
# }

################################################################################
# S3 Logging Bucket
################################################################################

module "s3_logs_bucket_us_west_2" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0"
  providers = {
    aws = aws.us_west_2
  }

  bucket_prefix = "msk-logs-us-west-2"

  acl                      = "log-delivery-write"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_lb_log_delivery_policy = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Environment = "production"
    Purpose     = "MSK-Logs"
  }
}

# COMMENTED OUT: Waiting for ec2:DescribeVpcs permission in ap-south-1 region
# module "s3_logs_bucket_ap_south_1" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "~> 5.0"
#   providers = {
#     aws = aws.ap_south_1
#   }

#   bucket_prefix = "msk-logs-ap-south-1"

#   acl                      = "log-delivery-write"
#   control_object_ownership = true
#   object_ownership         = "ObjectWriter"

#   attach_lb_log_delivery_policy = true

#   server_side_encryption_configuration = {
#     rule = {
#       apply_server_side_encryption_by_default = {
#         sse_algorithm = "AES256"
#       }
#     }
#   }

#   tags = {
#     Environment = "production"
#     Purpose     = "MSK-Logs"
#   }
# }

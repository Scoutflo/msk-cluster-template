################################################################################
# US West 2 (Oregon) - MSK Cluster
################################################################################

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}

data "aws_caller_identity" "us_west_2" {
  provider = aws.us_west_2
}

data "aws_vpc" "us_west_2" {
  provider = aws.us_west_2
  id       = "vpc-0c75af08774009569"
}

data "aws_subnets" "us_west_2_all" {
  provider = aws.us_west_2
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.us_west_2.id]
  }
}

data "aws_subnet" "us_west_2_all" {
  provider = aws.us_west_2
  for_each = toset(data.aws_subnets.us_west_2_all.ids)
  id       = each.value
}

locals {
  us_west_2_private_subnet_ids = length(var.us_west_2_private_subnet_ids) > 0 ? var.us_west_2_private_subnet_ids : [
    for s in data.aws_subnet.us_west_2_all : s.id if s.map_public_ip_on_launch == false
  ]
}

resource "aws_security_group" "us_west_2_msk" {
  provider = aws.us_west_2
  name     = "msk-cluster-sg-us-west-2"
  vpc_id   = data.aws_vpc.us_west_2.id

  ingress {
    description = "Kafka Broker"
    from_port   = 9092
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.us_west_2.cidr_block]
  }

  ingress {
    description = "Kafka Broker TLS"
    from_port   = 9094
    to_port     = 9096
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.us_west_2.cidr_block]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "msk-cluster-sg-us-west-2"
  }
}

module "msk_cluster_us_west_2" {
  source = "../../"
  providers = {
    aws = aws.us_west_2
  }

  name                   = "prod-flexprice-msk-us"
  kafka_version          = "3.5.1"
  number_of_broker_nodes = length(local.us_west_2_private_subnet_ids) >= 2 ? 2 : length(local.us_west_2_private_subnet_ids)
  enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"

  broker_node_client_subnets  = local.us_west_2_private_subnet_ids
  broker_node_instance_type   = "kafka.m7g.large"
  broker_node_security_groups = [aws_security_group.us_west_2_msk.id]

  broker_node_connectivity_info = {
    public_access = {
      type = "DISABLED"
    }
    vpc_connectivity = {
      client_authentication = {
        sasl = {
          iam   = false
          scram = false
        }
        tls = false
      }
    }
  }

  broker_node_storage_info = {
    ebs_storage_info = {
      volume_size = 100
    }
  }

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  encryption_at_rest_kms_key_arn = null

  client_authentication = {
    sasl = {
      iam   = true
      scram = false
    }
    tls = {
      certificate_authority_arns = []
    }
  }

  jmx_exporter_enabled    = true
  node_exporter_enabled   = true
  cloudwatch_logs_enabled = false
  s3_logs_enabled         = true
  s3_logs_bucket          = module.s3_logs_bucket_us_west_2.s3_bucket_id
  s3_logs_prefix          = "msk-logs"

  scaling_max_capacity = 512
  scaling_target_value = 80

  tags = {
    Environment = "production"
    Region      = "us-west-2"
    VPC         = "scoutflo-vpc-ziYcAo8t-flexprice-prod"
    Project     = "scoutflo"
  }

  create_cluster_policy = true
  cluster_policy_statements = {
    allow_kafka_access = {
      sid    = "AllowKafkaAccess"
      effect = "Allow"
      actions = [
        "kafka:CreateVpcConnection",
        "kafka:GetBootstrapBrokers",
        "kafka:DescribeCluster",
        "kafka:DescribeClusterV2"
      ]
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.us_west_2.account_id}:root"]
      }]
    }
  }
}

################################################################################
# AP South 1 (Mumbai) - MSK Cluster
# COMMENTED OUT: Waiting for ec2:DescribeVpcs permission in ap-south-1 region
# Uncomment this section once permissions are added
################################################################################

# provider "aws" {
#   alias  = "ap_south_1"
#   region = "ap-south-1"
# }

# data "aws_caller_identity" "ap_south_1" {
#   provider = aws.ap_south_1
# }

# data "aws_vpc" "ap_south_1" {
#   provider = aws.ap_south_1
#   id       = "vpc-00b163f7ebb585e41"
# }

# data "aws_subnets" "ap_south_1_all" {
#   provider = aws.ap_south_1
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.ap_south_1.id]
#   }
# }

# data "aws_subnet" "ap_south_1_all" {
#   provider = aws.ap_south_1
#   for_each = toset(data.aws_subnets.ap_south_1_all.ids)
#   id       = each.value
# }

# locals {
#   ap_south_1_private_subnet_ids = length(var.ap_south_1_private_subnet_ids) > 0 ? var.ap_south_1_private_subnet_ids : [
#     for s in data.aws_subnet.ap_south_1_all : s.id if s.map_public_ip_on_launch == false
#   ]
# }

# resource "aws_security_group" "ap_south_1_msk" {
#   provider = aws.ap_south_1
#   name     = "msk-cluster-sg-ap-south-1"
#   vpc_id   = data.aws_vpc.ap_south_1.id

#   ingress {
#     description = "Kafka Broker"
#     from_port   = 9092
#     to_port     = 9098
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.ap_south_1.cidr_block]
#   }

#   ingress {
#     description = "Kafka Broker TLS"
#     from_port   = 9094
#     to_port     = 9096
#     protocol    = "tcp"
#     cidr_blocks = [data.aws_vpc.ap_south_1.cidr_block]
#   }

#   egress {
#     description = "All outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "msk-cluster-sg-ap-south-1"
#   }
# }

# module "msk_cluster_ap_south_1" {
#   source = "../../"
#   providers = {
#     aws = aws.ap_south_1
#   }

#   name                   = "prod-flexprice-msk-india"
#   kafka_version          = "3.5.1"
#   number_of_broker_nodes = length(local.ap_south_1_private_subnet_ids) >= 2 ? 2 : length(local.ap_south_1_private_subnet_ids)
#   enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"

#   broker_node_client_subnets  = local.ap_south_1_private_subnet_ids
#   broker_node_instance_type   = "kafka.m7g.large"
#   broker_node_security_groups = [aws_security_group.ap_south_1_msk.id]

#   broker_node_connectivity_info = {
#     public_access = {
#       type = "DISABLED"
#     }
#     vpc_connectivity = {
#       client_authentication = {
#         sasl = {
#           iam   = false
#           scram = false
#         }
#         tls = false
#       }
#     }
#   }

#   broker_node_storage_info = {
#     ebs_storage_info = {
#       volume_size = 100
#     }
#   }

#   encryption_in_transit_client_broker = "TLS"
#   encryption_in_transit_in_cluster    = true

#   encryption_at_rest_kms_key_arn = null

#   client_authentication = {
#     sasl = {
#       iam   = true
#       scram = false
#     }
#     tls = {
#       certificate_authority_arns = []
#     }
#   }

#   jmx_exporter_enabled    = true
#   node_exporter_enabled   = true
#   cloudwatch_logs_enabled = false
#   s3_logs_enabled         = true
#   s3_logs_bucket          = module.s3_logs_bucket_ap_south_1.s3_bucket_id
#   s3_logs_prefix          = "msk-logs"

#   scaling_max_capacity = 512
#   scaling_target_value = 80

#   tags = {
#     Environment = "production"
#     Region      = "ap-south-1"
#     VPC         = "prod-flexprice/VPC"
#     Project     = "scoutflo"
#   }

#   create_cluster_policy = true
#   cluster_policy_statements = {
#     allow_kafka_access = {
#       sid    = "AllowKafkaAccess"
#       effect = "Allow"
#       actions = [
#         "kafka:CreateVpcConnection",
#         "kafka:GetBootstrapBrokers",
#         "kafka:DescribeCluster",
#         "kafka:DescribeClusterV2"
#       ]
#       principals = [{
#         type        = "AWS"
#         identifiers = ["arn:aws:iam::${data.aws_caller_identity.ap_south_1.account_id}:root"]
#       }]
#     }
#   }
# }

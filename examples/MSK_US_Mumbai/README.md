# MSK Clusters - US West 2 & Mumbai (AP South 1)

This example creates MSK clusters in two regions:
- **US West 2 (Oregon)**: `vpc-0c75af08774009569` (scoutflo-vpc-ziYcAo8t-flexprice-prod)
- **AP South 1 (Mumbai)**: `vpc-00b163f7ebb585e41` (prod-flexprice/VPC)

## Configuration Details

### Cluster Specifications
- **Instance Type**: `kafka.m7g.large`
- **Storage**: 100 GB per broker
- **Kafka Version**: 3.5.1
- **Broker Nodes**: 2 (for HA/2-AZ setup - cost optimized)
- **Monitoring**: Enhanced monitoring enabled (PER_TOPIC_PER_PARTITION)
- **Authentication**: SASL/IAM
- **Encryption**: TLS in transit, AWS managed KMS at rest
- **Logging**: S3 logging enabled (cost optimized)

### Network Configuration
- **VPC Connection**: Uses existing VPCs (does not create new VPCs)
- **Subnets**: Private subnets only (no public internet access)
- **Public Access**: Disabled
- **Security**: Security groups restrict access to VPC CIDR only

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform** >= 1.5.7 installed
3. **AWS Provider** >= 6.22.1
4. **Existing VPCs** with private subnets
5. **IAM Permissions** as specified in `../../IAM/index.json`

### Required IAM Permissions

The IAM role/user used for deployment must have permissions as defined in `../../IAM/index.json`, including:
- MSK cluster management (Create, Update, Delete, Describe)
- MSK configuration management
- EC2 permissions (Security Groups, VPC/Subnet read)
- CloudWatch Logs management
- Application AutoScaling
- KMS key management
- SNS topic management (for alerts)
- S3 bucket management (for logging)

**Note**: The IAM policy includes all necessary permissions for this deployment. See `../../IAM/index.json` for the complete policy.

## Subnet Discovery

**The configuration automatically selects the 2 private subnets from your VPC (2 private subnets minimum required).**

The code filters subnets by checking `map_public_ip_on_launch == false`, which identifies private subnets. Your VPC structure:
- ✅ **2 Private Subnets** (will be used - one per AZ for 2-AZ setup)
- ❌ **Public Subnets** (will be ignored)

### Find Your Private Subnet IDs

**For US West 2:**
```bash
aws ec2 describe-subnets \
  --region us-west-2 \
  --filters "Name=vpc-id,Values=vpc-0c75af08774009569" \
  --query 'Subnets[?MapPublicIpOnLaunch==`false`].[SubnetId,AvailabilityZone]' \
  --output table
```

**For AP South 1:**
```bash
aws ec2 describe-subnets \
  --region ap-south-1 \
  --filters "Name=vpc-id,Values=vpc-00b163f7ebb585e41" \
  --query 'Subnets[?MapPublicIpOnLaunch==`false`].[SubnetId,AvailabilityZone]' \
  --output table
```

### Manual Override (Optional)

If automatic discovery doesn't work, specify subnet IDs in `terraform.tfvars`:

```hcl
us_west_2_private_subnet_ids = [
  "subnet-xxxxx",
  "subnet-yyyyy"
]

ap_south_1_private_subnet_ids = [
  "subnet-aaaaa",
  "subnet-bbbbb"
]
```

## Usage

1. **Navigate to this directory**:
   ```bash
   cd examples/MSK_US_Mumbai
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan the deployment**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

5. **Get bootstrap broker endpoints**:
   ```bash
   terraform output -json
   ```

## Outputs

After deployment, you'll get:
- Cluster ARNs
- Bootstrap broker endpoints (TLS and SASL/IAM)
- Cluster names and UUIDs

**Note**: Bootstrap broker endpoints are marked as sensitive and won't display by default. Use `terraform output -json` to view them.

## Important Notes

### Subnet Requirements:
- **2 private subnets** (one per AZ) required for 2-AZ setup
- Subnets must be in different availability zones
- Number of broker nodes must match subnet count (2 brokers = 2 subnets)

### Security:
- Clusters are **private only** - no public endpoints
- Accessible only from within the VPC
- Use VPC peering or VPN for cross-VPC access

## Cost Considerations

- **kafka.m7g.large**: ~$0.30/hour per broker
- **Storage**: 100 GB EBS per broker
- **2-AZ Setup**: 2 brokers per cluster (cost optimized)
- **S3 Logging**: Enabled (cost optimized vs CloudWatch)
- Estimated monthly cost: ~$915/month for both regions
- See `AWS_COST_ANALYSIS.md` for detailed breakdown

## Production Readiness

This configuration is **production-ready** with:
- ✅ TLS encryption in transit and at rest
- ✅ SASL/IAM authentication
- ✅ Private subnets only (no public access)
- ✅ Multi-AZ high availability (2 brokers, 2 AZs)
- ✅ Enhanced monitoring and S3 logging (cost optimized)
- ✅ Storage autoscaling enabled
- ✅ CloudWatch alarms for storage utilization and under-replicated partitions
- ✅ SNS topic for alerting
- ✅ Customer-managed KMS keys (optional, can use AWS-managed)
- ✅ S3 logging buckets for long-term log storage

## File Structure

```
MSK_US_Mumbai/
├── main.tf                      # Main cluster configuration for both regions
├── monitoring-and-alerts.tf     # CloudWatch alarms, SNS, KMS keys, S3 logging
├── variables.tf                 # Input variables for subnet overrides
├── outputs.tf                   # Cluster outputs (ARNs, bootstrap brokers, etc.)
├── versions.tf                  # Terraform and provider version requirements
├── terraform.tfvars.example     # Example variables file
├── README.md                    # This file
└── AWS_COST_ANALYSIS.md         # Detailed cost breakdown and analysis
```

## Monitoring and Alerts

The `monitoring-and-alerts.tf` file includes:

### CloudWatch Alarms (4 alarms)
- **Storage Utilization Alarms**: Alert when storage exceeds 85% (2 alarms)
- **Under-Replicated Partitions Alarms**: Alert when partitions are under-replicated (2 alarms)

### SNS Topic
- **Topic**: `msk-cluster-alerts`
- **Email Subscription**: Update `your-team@example.com` in `monitoring-and-alerts.tf`

### Customer-Managed KMS Keys (Optional)
- 2 KMS keys (one per region) with automatic rotation enabled
- **Note**: Currently using AWS-managed KMS keys. To use customer-managed keys, update `main.tf`:
  ```hcl
  encryption_at_rest_kms_key_arn = aws_kms_key.msk_us_west_2.arn
  encryption_at_rest_kms_key_arn = aws_kms_key.msk_ap_south_1.arn
  ```

### S3 Logging Buckets
- 2 S3 buckets for MSK log storage (one per region)
- **Status**: ✅ Enabled and configured in `main.tf`
- **Cost**: ~$0.33/month (vs ~$5.12/month for CloudWatch Logs)
- Provides cost-effective long-term log storage

## Cost Analysis

See `AWS_COST_ANALYSIS.md` for detailed cost breakdown:
- **Optimized Configuration**: ~$915/month (2-AZ, S3 logging)
- **Previous Configuration**: ~$1,377/month (3-AZ, CloudWatch logs)
- **Monthly Savings**: ~$462/month (33.5% reduction)
- **Annual Cost**: ~$10,984/year

## Troubleshooting

### Error: "No subnets found"
- **Solution**: Manually specify subnet IDs in `terraform.tfvars`
- Verify subnets have `MapPublicIpOnLaunch = false`

### Error: "Number of broker nodes must be multiple of subnet count"
- **Solution**: Ensure you have exactly 2 subnets for 2 brokers (one per AZ for 2-AZ setup)

### Error: "Insufficient permissions"
- **Solution**: Check `../../IAM/index.json` for required permissions


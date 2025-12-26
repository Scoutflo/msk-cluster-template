# MSK Clusters - US West 2 & AP South 2 (Internal Testing)

This example creates MSK clusters in two regions for internal testing:
- **US West 2 (Oregon)**: `vpc-0910d5a44fb9ec99d`
- **AP South 2 (Hyderabad)**: `vpc-0e794b48cb49e3156`

## Configuration Details

### Cluster Specifications
- **Instance Type**: `kafka.m7g.large`
- **Storage**: 100 GB per broker
- **Kafka Version**: 3.5.1
- **Broker Nodes**: 3 (for HA/multi-AZ)
- **Monitoring**: Enhanced monitoring enabled (PER_TOPIC_PER_PARTITION)
- **Authentication**: SASL/IAM
- **Encryption**: TLS in transit, AWS managed KMS at rest

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

## Subnet Discovery

**The configuration automatically selects the 3 private subnets from your 6 total subnets (3 private + 3 public).**

The code filters subnets by checking `map_public_ip_on_launch == false`, which identifies private subnets. Your VPC structure:
- ✅ **3 Private Subnets** (will be used - one per AZ)
- ❌ **3 Public Subnets** (will be ignored)

### Find Your Private Subnet IDs

**For US West 2:**
```bash
aws ec2 describe-subnets \
  --region us-west-2 \
  --filters "Name=vpc-id,Values=vpc-0910d5a44fb9ec99d" \
  --query 'Subnets[?MapPublicIpOnLaunch==`false`].[SubnetId,AvailabilityZone]' \
  --output table
```

**For AP South 2:**
```bash
aws ec2 describe-subnets \
  --region ap-south-2 \
  --filters "Name=vpc-id,Values=vpc-0e794b48cb49e3156" \
  --query 'Subnets[?MapPublicIpOnLaunch==`false`].[SubnetId,AvailabilityZone]' \
  --output table
```

### Manual Override (Optional)

If automatic discovery doesn't work, specify subnet IDs in `terraform.tfvars`:

```hcl
us_west_2_private_subnet_ids = [
  "subnet-xxxxx",
  "subnet-yyyyy",
  "subnet-zzzzz"
]

ap_south_2_private_subnet_ids = [
  "subnet-aaaaa",
  "subnet-bbbbb",
  "subnet-ccccc"
]
```

## Usage

1. **Navigate to this directory**:
   ```bash
   cd examples/MSK_US_Mumbai_Internal
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
- **3 private subnets** (one per AZ) required
- Subnets must be in different availability zones
- Number of broker nodes must match subnet count

### Security:
- Clusters are **private only** - no public endpoints
- Accessible only from within the VPC
- Use VPC peering or VPN for cross-VPC access

## Cost Considerations

- **kafka.m7g.large**: ~$0.30/hour per broker
- **Storage**: 100 GB EBS per broker
- Estimated monthly cost: ~$1,316/month for both regions

## Production Readiness

This configuration is **production-ready** with:
- ✅ TLS encryption in transit and at rest
- ✅ SASL/IAM authentication
- ✅ Private subnets only (no public access)
- ✅ Multi-AZ high availability (3 brokers)
- ✅ Enhanced monitoring and CloudWatch logs
- ✅ Storage autoscaling enabled

See `production-enhancements.tf` for optional enhancements like CloudWatch alarms, customer-managed KMS keys, and S3 logging.

## Troubleshooting

### Error: "No subnets found"
- **Solution**: Manually specify subnet IDs in `terraform.tfvars`
- Verify subnets have `MapPublicIpOnLaunch = false`

### Error: "Number of broker nodes must be multiple of subnet count"
- **Solution**: Ensure you have exactly 3 subnets for 3 brokers (one per AZ)

### Error: "Insufficient permissions"
- **Solution**: Check `../../IAM/index.json` for required permissions


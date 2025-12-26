# MSK Cluster Examples

This directory contains example configurations for deploying MSK clusters.

## Available Examples

### MSK_US_Mumbai

Production-ready configuration for deploying MSK clusters in two regions:
- **US West 2 (Oregon)**: Connects to existing VPC `vpc-0c75af08774009569`
- **AP South 1 (Mumbai)**: Connects to existing VPC `vpc-00b163f7ebb585e41`

**Usage:**
```bash
cd examples/MSK_US_Mumbai
terraform init
terraform plan
terraform apply
```

See the [README](MSK_US_Mumbai/README.md) in that directory for detailed documentation.

### MSK_US_Mumbai_Internal

Internal testing configuration for deploying MSK clusters in two regions:
- **US West 2 (Oregon)**: Connects to existing VPC `vpc-0910d5a44fb9ec99d`
- **AP South 2 (Hyderabad)**: Connects to existing VPC `vpc-0e794b48cb49e3156`

**Key Features:**
- ✅ Connects to existing VPCs (does not create new VPCs)
- ✅ Automatically discovers and uses private subnets
- ✅ Multi-region deployment (US and Mumbai)
- ✅ Production-ready configuration with encryption, monitoring, and HA
- ✅ 3 brokers per cluster (one per availability zone)
- ✅ Instance type: `kafka.m7g.large`
- ✅ Storage: 100 GB per broker

**Usage:**
```bash
cd examples/MSK_US_Mumbai_Internal
terraform init
terraform plan
terraform apply
```

See the [README](MSK_US_Mumbai_Internal/README.md) in that directory for detailed documentation.

## Module Documentation

For complete module documentation, see the [main README](../README.md) in the root directory.

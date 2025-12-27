# AWS Cost Analysis - MSK_US_Mumbai Configuration (Updated)

## 📊 **Complete Cost Breakdown - Cost Optimized Configuration**

**Date**: 2025-12-26  
**Configuration**: `examples/MSK_US_Mumbai`  
**Regions**: US West 2 (Oregon) & AP South 1 (Mumbai)  
**Optimizations**: 2-AZ setup, S3 logging instead of CloudWatch

---

## 💰 **PART 1: ACTIVE RESOURCES (Currently Created)**

### **1. MSK Clusters (2 clusters) - 2-AZ Setup**

#### **US West 2 Cluster**
- **Instance Type**: `kafka.m7g.large`
- **Number of Brokers**: 2 (2-AZ setup for cost optimization)
- **Storage per Broker**: 100 GB (gp3 EBS)
- **Region**: us-west-2
- **Cluster Name**: `prod-flexprice-msk-us`

**Cost Calculation:**
- **Broker Instances**: 2 brokers × $0.30/hour × 730 hours/month = **$438.00/month**
- **EBS Storage**: 2 brokers × 100 GB × $0.08/GB/month = **$16.00/month**
- **Subtotal US West 2**: **$454.00/month**

#### **AP South 1 Cluster**
- **Instance Type**: `kafka.m7g.large`
- **Number of Brokers**: 2 (2-AZ setup for cost optimization)
- **Storage per Broker**: 100 GB (gp3 EBS)
- **Region**: ap-south-1
- **Cluster Name**: `prod-flexprice-msk-india`

**Cost Calculation:**
- **Broker Instances**: 2 brokers × $0.30/hour × 730 hours/month = **$438.00/month**
- **EBS Storage**: 2 brokers × 100 GB × $0.08/GB/month = **$16.00/month**
- **Subtotal AP South 1**: **$454.00/month**

**MSK Clusters Total**: **$908.00/month** (saved $454/month vs 3-AZ setup)

---

### **2. Security Groups (2 groups)**
- **Cost**: **$0.00/month** (Free)

---

### **3. S3 Logging (2 buckets) - Cost Optimized**

**Assumptions:**
- Log storage: ~5 GB/month per cluster (moderate usage)
- Standard storage class
- 30-day retention

**Cost Calculation:**
- **S3 Storage**: 2 buckets × 5 GB × $0.023/GB/month = **$0.23/month**
- **PUT Requests**: 2 buckets × 10,000 requests × $0.005/1,000 = **$0.10/month**
- **GET Requests**: Negligible (~$0.00/month)
- **S3 Logging Total**: **$0.33/month**

**Cost Savings vs CloudWatch:**
- **CloudWatch Logs**: ~$5.12/month (ingestion + storage)
- **S3 Logging**: ~$0.33/month
- **Savings**: **$4.79/month** ✅

---

### **4. Application AutoScaling (4 resources)**
- **Scalable Targets**: 2 (Free)
- **Scaling Policies**: 2 (Free)
- **Cost**: **$0.00/month** (Free)

---

### **5. MSK Configurations (2 configurations)**
- **Cost**: **$0.00/month** (Free)

---

### **6. CloudWatch Alarms (4 alarms)**
- **Cost**: **$0.00/month** (First 10 alarms free)

---

### **7. SNS Topic (1 topic, 1 subscription)**
- **Cost**: **$0.00/month** (First 1M requests/month free)

---

### **8. Customer-Managed KMS Keys (2 keys, 2 aliases)**
- **KMS Key**: $1.00/key/month
- **KMS Alias**: Free
- **KMS API Requests**: ~$0.03/month
- **KMS Total**: **$2.03/month**

---

### **9. Data Transfer Costs**
- **Internal VPC traffic**: Free
- **Cross-AZ data transfer**: Minimal
- **Estimated**: **$5.00/month** (conservative estimate)

---

## 📈 **PART 1 TOTAL: ACTIVE RESOURCES**

| Resource | Monthly Cost |
|----------|-------------|
| MSK Clusters (2 brokers × 2 regions) | $908.00 |
| Security Groups (2) | $0.00 |
| S3 Logging (2 buckets) | $0.33 |
| AutoScaling (4) | $0.00 |
| MSK Configurations (2) | $0.00 |
| CloudWatch Alarms (4) | $0.00 |
| SNS Topic & Subscription | $0.00 |
| KMS Keys (2) | $2.03 |
| Data Transfer | $5.00 |
| **TOTAL (Active)** | **$915.36/month** |

**Annual Cost (Active)**: **$10,984.32/year**

---

## 💰 **PART 2: COST COMPARISON**

### **Before Optimizations (3-AZ, CloudWatch Logs)**
- MSK Clusters: $1,362.00/month (3 brokers × 2 regions)
- CloudWatch Logs: $5.12/month
- **Total**: **$1,377.12/month**

### **After Optimizations (2-AZ, S3 Logging)**
- MSK Clusters: $908.00/month (2 brokers × 2 regions)
- S3 Logging: $0.33/month
- **Total**: **$915.36/month**

### **💰 Monthly Savings: $461.76/month**
### **💰 Annual Savings: $5,541.12/year**

---

## 📊 **Cost Breakdown by Service**

| Service | Monthly Cost (Optimized) | Monthly Cost (Previous) | Savings |
|---------|-------------------------|------------------------|---------|
| **MSK Clusters** | $908.00 | $1,362.00 | **$454.00** |
| **EBS Storage** | $32.00 | $48.00 | **$16.00** |
| **S3 Logging** | $0.33 | - | - |
| **CloudWatch Logs** | $0.00 | $5.12 | **$5.12** |
| **KMS Keys** | $2.03 | $0.00 | -$2.03 |
| **Data Transfer** | $5.00 | $10.00 | **$5.00** |
| **Other Services** | $0.00 | $0.00 | - |
| **TOTAL** | **$915.36** | **$1,377.12** | **$461.76** |

---

## 🎯 **Key Optimizations Applied**

### **1. Reduced from 3-AZ to 2-AZ**
- **Before**: 3 brokers per cluster (6 total)
- **After**: 2 brokers per cluster (4 total)
- **Savings**: $454/month (33% reduction in broker costs)

### **2. Switched from CloudWatch to S3 Logging**
- **Before**: CloudWatch Logs ($5.12/month)
- **After**: S3 Logging ($0.33/month)
- **Savings**: $4.79/month (93% reduction in logging costs)

### **3. Cluster Naming**
- **Cluster Names**: `prod-flexprice-msk-us`, `prod-flexprice-msk-india`
- **Tags**: Include `Project = "scoutflo"` for identification

---

## 💡 **Cost Optimization Summary**

| Metric | Value |
|--------|-------|
| **Monthly Cost (Optimized)** | $915.36 |
| **Annual Cost (Optimized)** | $10,984.32 |
| **Monthly Savings** | $461.76 |
| **Annual Savings** | $5,541.12 |
| **Savings Percentage** | 33.5% |

---

## ⚠️ **Important Notes**

1. **2-AZ Setup**: Still provides high availability with 2 brokers in different AZs
2. **S3 Logging**: More cost-effective for long-term log storage
3. **Storage Autoscaling**: Still enabled (max 512 GB per broker)
4. **All Security Features**: Maintained (encryption, authentication, monitoring)

---

## ✅ **Conclusion**

**Optimized Configuration Cost**: **~$915/month** or **~$10,984/year**

**Savings**: **$462/month** or **$5,541/year** (33.5% reduction)

The configuration is now cost-optimized while maintaining:
- ✅ High availability (2-AZ)
- ✅ All security features
- ✅ Monitoring and alerting
- ✅ Production readiness

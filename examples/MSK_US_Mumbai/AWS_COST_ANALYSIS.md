# AWS Cost Analysis - MSK_US_Mumbai Configuration

**Regions**: US West 2 (Oregon) & AP South 1 (Mumbai)

---

## 💰 **PART 1: ACTIVE RESOURCES (Currently Created)**

### **1. MSK Clusters (2 clusters)**

#### **US West 2 Cluster**
- **Instance Type**: `kafka.m7g.large`
- **Number of Brokers**: 3
- **Storage per Broker**: 100 GB (gp3 EBS)
- **Region**: us-west-2

**Cost Calculation:**
- **Broker Instances**: 3 brokers × $0.30/hour × 730 hours/month = **$657.00/month**
- **EBS Storage**: 3 brokers × 100 GB × $0.08/GB/month = **$24.00/month**
- **Subtotal US West 2**: **$681.00/month**

#### **AP South 1 Cluster**
- **Instance Type**: `kafka.m7g.large`
- **Number of Brokers**: 3
- **Storage per Broker**: 100 GB (gp3 EBS)
- **Region**: ap-south-1

**Cost Calculation:**
- **Broker Instances**: 3 brokers × $0.30/hour × 730 hours/month = **$657.00/month**
- **EBS Storage**: 3 brokers × 100 GB × $0.08/GB/month = **$24.00/month**
- **Subtotal AP South 1**: **$681.00/month**

**MSK Clusters Total**: **$1,362.00/month**

---

### **2. Security Groups (2 groups)**
- **Cost**: **$0.00/month** (Free)

---

### **3. CloudWatch Logs (2 log groups)**

**Assumptions:**
- Log ingestion: ~5 GB/month per cluster (moderate usage)
- Log retention: 7 days (default)

**Cost Calculation:**
- **Log Ingestion**: 2 clusters × 5 GB × $0.50/GB = **$5.00/month**
- **Log Storage**: 2 clusters × 2 GB (average) × $0.03/GB/month = **$0.12/month**
- **CloudWatch Logs Total**: **$5.12/month**

---

### **4. Application AutoScaling (4 resources)**
- **Scalable Targets**: 2 (Free)
- **Scaling Policies**: 2 (Free)
- **Cost**: **$0.00/month** (Free)

---

### **5. MSK Configurations (2 configurations)**
- **Cost**: **$0.00/month** (Free)

---

### **6. Data Transfer Costs**

**Assumptions:**
- Internal VPC traffic: Free
- Cross-AZ data transfer: Minimal
- Estimated: **$10.00/month** (conservative estimate)

---

## 📈 **PART 1 TOTAL: ACTIVE RESOURCES**

| Resource | Monthly Cost |
|----------|-------------|
| MSK Clusters (2) | $1,362.00 |
| Security Groups (2) | $0.00 |
| CloudWatch Logs (2) | $5.12 |
| AutoScaling (4) | $0.00 |
| MSK Configurations (2) | $0.00 |
| Data Transfer | $10.00 |
| **TOTAL (Active)** | **$1,377.12/month** |

**Annual Cost (Active)**: **$16,525.44/year**

---

## 💰 **PART 2: OPTIONAL ENHANCEMENTS**

### **1. CloudWatch Metric Alarms (4 alarms)**

**Resources:**
- 2 storage utilization alarms (US West 2, AP South 1)
- 2 under-replicated partition alarms (US West 2, AP South 1)

**Cost Calculation:**
- **First 10 alarms**: Free
- **Additional alarms**: $0.10/alarm/month (if > 10 total)
- **Cost**: **$0.00/month** (Within free tier)

**CloudWatch Alarms Total**: **$0.00/month**

---

### **2. SNS Topic and Subscription (1 topic, 1 subscription)**

**Resources:**
- 1 SNS topic: `msk-cluster-alerts`
- 1 email subscription

**Cost Calculation:**
- **SNS Topic**: Free (first 1M requests/month)
- **Email Subscription**: Free
- **Publishing to SNS**: $0.50 per 1M requests (assume 1000 alerts/month = negligible)
- **SNS Total**: **$0.00/month** (Within free tier)

---

### **3. Customer-Managed KMS Keys (2 keys, 2 aliases)**

**Resources:**
- 2 KMS keys (US West 2, AP South 1)
- 2 KMS aliases (US West 2, AP South 1)

**Cost Calculation:**
- **KMS Key**: $1.00/key/month
- **KMS Alias**: Free
- **KMS API Requests**: $0.03 per 10,000 requests (assume 10,000 requests/month = $0.03)
- **KMS Total**: 2 keys × $1.00 + $0.03 = **$2.03/month**

---

### **4. S3 Logging Buckets (2 buckets)**

**Resources:**
- 2 S3 buckets for MSK logs (US West 2, AP South 1)

**Assumptions:**
- Log storage: 50 GB/month per bucket (moderate logging)
- Standard storage class
- 30-day retention

**Cost Calculation:**
- **S3 Storage**: 2 buckets × 50 GB × $0.023/GB/month = **$2.30/month**
- **PUT Requests**: 2 buckets × 10,000 requests × $0.005/1,000 = **$0.10/month**
- **GET Requests**: 2 buckets × 1,000 requests × $0.0004/1,000 = **$0.00/month** (negligible)
- **S3 Total**: **$2.40/month**

---

## 📈 **PART 2 TOTAL: OPTIONAL ENHANCEMENTS**

| Resource | Monthly Cost |
|----------|-------------|
| CloudWatch Alarms (4) | $0.00 |
| SNS Topic & Subscription | $0.00 |
| Customer-Managed KMS Keys (2) | $2.03 |
| S3 Logging Buckets (2) | $2.40 |
| **TOTAL (Enhancements)** | **$4.43/month** |

**Annual Cost (Enhancements)**: **$53.16/year**

---

## 🎯 **COMPLETE COST SUMMARY**

### **Scenario 1: Current Configuration (Active Resources Only)**
- **Monthly Cost**: **$1,377.12**
- **Annual Cost**: **$16,525.44**

### **Scenario 2: With All Enhancements Enabled**
- **Monthly Cost**: **$1,381.55** ($1,377.12 + $4.43)
- **Annual Cost**: **$16,578.60**

---

## 📋 **Cost Breakdown by Service**

| Service | Monthly Cost (Active) | Monthly Cost (With Enhancements) |
|---------|----------------------|--------------------------------|
| **MSK Clusters** | $1,362.00 | $1,362.00 |
| **EBS Storage** | $48.00 | $48.00 |
| **CloudWatch Logs** | $5.12 | $5.12 |
| **CloudWatch Alarms** | $0.00 | $0.00 |
| **SNS** | $0.00 | $0.00 |
| **KMS (Customer-Managed)** | $0.00 | $2.03 |
| **S3 Logging** | $0.00 | $2.40 |
| **Data Transfer** | $10.00 | $10.00 |
| **Security Groups** | $0.00 | $0.00 |
| **AutoScaling** | $0.00 | $0.00 |
| **TOTAL** | **$1,377.12** | **$1,381.55** |

---
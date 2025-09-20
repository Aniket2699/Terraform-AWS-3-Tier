# Terraform AWS 3-Tier Architecture 🚀

This project provisions a **3-Tier Architecture on AWS** using Terraform.  
It consists of a **VPC**, **public subnet for web servers**, **private subnet for application servers**, and a **database layer (RDS)**.  
The setup ensures high availability, scalability, and separation of concerns between layers.

---

## 📌 Architecture

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/de267d27-0d7f-468d-bebc-8f677ee3115b" />

**Layers:**
1. **Web Tier (Public Subnet)**  
   - EC2 instances running Nginx/Apache  
   - Accessible via Internet Gateway & Security Groups  

2. **App Tier (Private Subnet)**  
   - EC2 instances hosting application code (e.g., PHP, Node.js, Java)  
   - Communicates only with Web Tier & DB Tier  

3. **DB Tier (Private Subnet)**  
   - AWS RDS (MySQL/PostgreSQL) or EC2-based database  
   - No direct internet access  
   - Security Groups restrict access only from App Tier  

---

## 🛠️ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.6`
- AWS CLI configured with access/secret keys
- An existing **AWS account**
- SSH key pair for EC2 login

---

#
   cd 3-Tier-Project
# Initialize Terraform
terraform init

# Validate Terraform configuration
terraform validate

# Preview resources
terraform plan

# Apply configuration
terraform apply -auto-approve

📤 Outputs
After a successful deployment, Terraform will output:

VPC ID

Public Subnet IDs

Private Subnet IDs

EC2 Public IPs (Web servers)

RDS Endpoint (if provisioned)

# You can test the web server:

curl http://<web-public-ip>

🧹 Destroy Resources
# To clean up the AWS infrastructure:
terraform destroy -auto-approve

# 🔐 Security Considerations

Only Web Tier is publicly accessible.

App Tier and DB Tier reside in private subnets.

Security Groups enforce least privilege.

# Optionally enable:

NACLs for subnet-level security

AWS KMS encryption for RDS and EBS volumes

# 🚀 Future Improvements

Add Load Balancer (ALB/ELB) for Web Tier

Configure Auto Scaling Groups

Enable CloudWatch monitoring & alarms

Implement CI/CD pipeline with GitHub Actions or Jenkins

Add WAF (Web Application Firewall) for extra security

# 👨‍💻 Author
Aniket Dauskar

AWS | Azure | DevOps | Terraform Enthusiast



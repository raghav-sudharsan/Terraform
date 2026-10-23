cd /mnt/c/Users/ragha/OneDrive/Documents/DevOps/TechAspirant/Abhishek/ultimate-devops-project-demo/EKS/backend

# 1. What does Terraform think it manages?
terraform state list

# 2. Where is state coming from? Look for a backend block
grep -n "backend" *.tf
ls -la terraform.tfstate* .terraform/ 2>/dev/null
cat .terraform/terraform.tfstate 2>/dev/null | head -30

# 3. Confirm the resources really exist in AWS
aws s3api head-bucket --bucket terraform-eks-bucket-state
aws dynamodb describe-table --table-name terraform-locks --query 'Table.TableStatus'

# 4. Confirm you're on the right account/region
aws sts get-caller-identity
aws configure get region

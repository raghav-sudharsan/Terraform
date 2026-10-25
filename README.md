# Ultimate DevOps Project Demo

This directory contains DevOps learning notes and example configurations for the OpenTelemetry demo e-commerce application. It covers Docker image builds, Kubernetes basics, and Terraform-based AWS infrastructure. The application source code itself is not included here.

## Contents

- `1-Project.txt` — project overview, environment setup, and troubleshooting notes.
- `2-DockerLifecycle.txt` — Docker build and container lifecycle notes for Go, Java, and Python services.
- `3-Dockerfile_go.yml`, `4-Dockerfile_java.yml`, `5-Dockerfile_python.yml` — example Dockerfile contents for the Product Catalog, Ad, and Recommendation services. These examples expect the corresponding service source and build files in the Docker build context.
- `Kubernates.txt` — Kubernetes concepts, resource examples, cluster contexts, and deployment commands.
- `Terraform.txt` — Terraform workflow, state, modules, and AWS CLI notes.
- `EKS/` — Terraform configuration for an AWS VPC and EKS cluster, plus a separate Terraform configuration for bootstrapping the S3 state bucket and DynamoDB lock table.

## Requirements

Install and configure the tools needed for the task you want to follow:

- Docker, for building and running the service images.
- Terraform, for provisioning or inspecting the AWS infrastructure.
- AWS CLI credentials authorized for the target AWS account.
- `kubectl`, for connecting to and inspecting an EKS cluster.

Do not commit AWS credentials, Terraform state files, or other secrets.

## AWS Terraform infrastructure

The EKS stack is in `EKS/`. Its default configuration uses AWS region `ap-south-1`, VPC CIDR `10.0.0.0/16`, three private and three public subnets, an EKS cluster named `my-eks-cluster`, and a managed node group named `general`. Values are defined in `EKS/variables.tf` and can be overridden with Terraform variable files or command-line options.

The EKS root configures an S3 remote backend using bucket `terraform-eks-bucket-state`, key `terraform.tfstate`, and DynamoDB table `terraform-locks`. The backend resources are declared separately under `EKS/backend/`; bootstrap that configuration before initializing the EKS stack:

```bash
aws sts get-caller-identity

cd EKS/backend
terraform init
terraform plan
terraform apply

cd ..
terraform init
terraform workspace show
terraform plan
```

The S3 bucket name must be available and globally unique. If the bucket or lock table already exists, inspect it and its state before applying the bootstrap configuration. Do not delete the backend bucket to fix Terraform errors: it stores the EKS stack's state, and deleting state does not delete the AWS resources. If state is missing, recover it from S3 version history or a backup before considering resource imports.

Review the Terraform plan before applying infrastructure changes:

```bash
terraform apply
```

To inspect resources recorded in the current workspace:

```bash
terraform workspace show
terraform state list
terraform show
```

After confirming the state is valid, check for drift without applying changes:

```bash
terraform plan -refresh-only
```

Terraform resources can incur AWS charges. Review the plan and expected costs before creating infrastructure. Do not run `terraform destroy` unless you intend to remove the managed infrastructure.

## Connect to the EKS cluster

After the cluster exists and Terraform outputs its name, configure `kubectl` for it:

```bash
aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster
kubectl config current-context
kubectl get nodes
kubectl get pods --all-namespaces
```

Confirm that the current context and AWS account are the intended ones before running commands that change cluster resources.

## Docker examples

The Dockerfile examples are snippets intended for use with the matching service source, not standalone application directories. Build from the relevant service directory (or adjust the build context and file path as needed), for example:

```bash
docker build -f Dockerfile -t product-catalog:local .
```

The example images use Go 1.22 for Product Catalog, Eclipse Temurin 21 for the Java Ad service, and Python 3.12 for the Recommendation service.

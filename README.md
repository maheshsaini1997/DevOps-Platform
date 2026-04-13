# DevOps Platform (GitOps + EKS + Terraform)

This project demonstrates a complete DevOps platform that automates infrastructure provisioning, application deployment, and monitoring using modern best practices.

The focus is not just on deploying an application, but on building a production-like system with GitOps, CI/CD automation, and full observability.

--------------------------------------------------

WHAT THIS PROJECT DOES

- Provisions AWS infrastructure using Terraform
- Builds and pushes Docker images via GitHub Actions
- Deploys applications to EKS using Helm and ArgoCD (GitOps)
- Automatically updates deployments on code changes
- Monitors infrastructure and applications using Prometheus and Grafana

--------------------------------------------------

ARCHITECTURE OVERVIEW

Developer -> GitHub -> GitHub Actions (CI)
                      ↓
              Docker Image -> AWS ECR
                      ↓
          Helm values updated (commit SHA)
                      ↓
                  Git updated
                      ↓
              ArgoCD (GitOps)
                      ↓
              Kubernetes (EKS)
                      ↓
        Prometheus -> Grafana (Monitoring)

--------------------------------------------------

TECH STACK

Cloud: AWS (EKS, ECR, IAM, VPC)
IaC: Terraform
CI: GitHub Actions
CD: ArgoCD (GitOps)
Containerization: Docker
Orchestration: Kubernetes (EKS)
Package Management: Helm
Monitoring: Prometheus, Grafana

--------------------------------------------------

PROJECT STRUCTURE

DevOps-Platform/
│
├── terraform-infra/
│   ├── environments/
│   │   └── dev/
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       └── ecr/
│
├── application-microservices/
│   └── user-service/
│       ├── Dockerfile
│       └── application code
│
├── helm/
│   └── user-service/
│       ├── templates/
│       ├── values.yaml
│       └── values-dev.yaml
│
├── .github/workflows/
│   ├── reusable-build.yaml
│   ├── user-service.yaml
│   ├── terraform-plan.yaml
│   └── terraform-apply.yaml

--------------------------------------------------

CI/CD FLOW

CI (GitHub Actions)
- Triggered on code changes
- Builds Docker image
- Tags image using commit SHA
- Pushes image to ECR
- Updates values-dev.yaml with new image tag
- Pushes change back to repo

CD (ArgoCD - GitOps)
- Watches Git repository
- Detects changes in Helm values
- Automatically syncs and deploys to EKS
- No manual kubectl apply

--------------------------------------------------

HELM CONFIGURATION

image:
  registry: <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com
  repository: dev-user-service
  tag: latest

The pipeline replaces tag dynamically with commit SHA.

--------------------------------------------------

WHY NOT USE LATEST TAG?

- Not versioned
- Hard to debug
- No rollback control

Instead:
dev-user-service:<commit-sha>

--------------------------------------------------

TERRAFORM SETUP

- Remote state stored in S3
- State locking using DynamoDB

Pipelines:
- terraform plan -> automatic
- terraform apply -> manual approval

--------------------------------------------------

OBSERVABILITY

Installed using kube-prometheus-stack

Includes:
- Prometheus
- Grafana
- Node Exporter
- kube-state-metrics

Monitors:
- Node CPU / Memory
- Pod usage
- Application metrics
- Resource consumption

--------------------------------------------------

KEY LEARNINGS

- CI should not deploy directly
- Git should be source of truth
- Use parameterization instead of hardcoding
- Observability is critical
- Terraform should follow plan + approval

--------------------------------------------------

HOW TO RUN

1. Provision Infrastructure
cd terraform-infra/environments/dev
terraform init
terraform apply

2. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>

3. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

4. Install Monitoring
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

5. Deploy Application
Push code -> pipeline runs -> deployment happens automatically

--------------------------------------------------

CLEANUP

terraform destroy

--------------------------------------------------

FINAL THOUGHTS

This project focuses on building a realistic DevOps workflow, not just deploying an application.

It covers:
- Infrastructure lifecycle
- Automated CI/CD
- GitOps principles
- Monitoring & observability

Feedback is always welcome.
provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token

  alias = "eks"
}
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "vpc" {
  source      = "../../modules/vpc"
  environment = "dev"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  availability_zones = ["us-east-1a", "us-east-1b"]

}

module "ecr" {
  source      = "../../modules/ecr"
  environment = "dev"

  repository_names = [
    "user-service",
    "payment-service",
    "notification-service"
  ]
}

module "eks" {
  source          = "../../modules/eks"
  environment     = "dev"
  cluster_name    = "platform"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
resource "kubernetes_namespace" "argocd" {

  depends_on = [module.eks]
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  depends_on = [module.eks]
  name       = "argocd"
  namespace  = "argocd"

  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
EOF
  ]
}

resource "kubernetes_manifest" "root_app" {

  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "root-app"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/maheshsaini1997/DevOps-Platform"
        targetRevision = "HEAD"
        path           = "argocd/applications/dev"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}
resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.environment}-${var.cluster_name}-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "cluster" {
    name = "${var.environment}-${var.cluster_name}"
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
      subnet_ids = var.private_subnets
    }

    depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy ]
  
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.environment}-${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_node_group" "nodes" {
  cluster_name = aws_eks_cluster.cluster.name
  node_group_name = "${var.environment}-node"
  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = var.private_subnets

  scaling_config {
    desired_size = 2
    max_size = 3
    min_size = 1
  }

  instance_types = [ "t3.micro" ]

  depends_on = [ 
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
   ]
}
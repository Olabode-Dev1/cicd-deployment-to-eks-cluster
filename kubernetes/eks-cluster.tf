resource "aws_iam_user_policy_attachment" "user_eks_policy" {
  user       = "your-iam-username"  # Replace with your IAM username
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "user_eks_vpc_policy" {
  user       = "your-iam-username"  # Replace with your IAM username
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = <<EOF
- userarn: arn:aws:iam::<account-id>:user/your-iam-username  # Replace with your IAM user ARN
  username: your-iam-username  # Replace with your IAM username
  groups:
    - system:masters
EOF
  }
} 

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31.0"

  cluster_name    = "myAppp-eks-cluster"
  cluster_version = "1.27"
  subnet_ids      = module.myAppp-vpc.private_subnets
  vpc_id          = module.myAppp-vpc.vpc_id

  cluster_endpoint_public_access = true
  cluster_addons = {
    coredns = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni = { most_recent = true }
  }

  eks_managed_node_groups = {
    dev = {
      desired_size   = 3
      max_size       = 6
      min_size       = 1
      instance_types = ["t2.small"]
      key_name       = "virginia-kp"
      ami_type       = "AL2_x86_64"
      disk_size      = 20

      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      ]

      tags = {
        environment = "development"
        application = "myAppp"
      }
    }
  }
}

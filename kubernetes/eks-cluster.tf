module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31.0"

  cluster_name    = "myAppp-eks-cluster"
  cluster_version = "1.27"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_endpoint_public_access = true
  cluster_addons = {
    coredns = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni = { most_recent = true }
  }

  iam_role_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]

  eks_managed_node_groups = {
    dev = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t2.small"]
      key_name       = "virginia-kp"
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      ]
    }
  }

  tags = {
    environment = "development"
    application = "myAppp"
  }
}

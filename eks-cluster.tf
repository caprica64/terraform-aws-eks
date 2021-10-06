module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  # When using local VPC creation, commented out otherwise
  #subnets         = module.vpc.private_subnets
  # When using subnets and VPC created outside the cluster
  subnets         = ["subnet-0351a99c25dc3fbc3","subnet-08cfcfb5879fcf765","subnet-0533a467a064dfbbb"]
  cluster_enabled_log_types = ["api", "audit", "authenticator", "scheduler", "controllerManager"]
  
  cluster_encryption_config = [
    {
      provider_key_arn = var.kms_arn
      resources        = ["secrets"]
    }
  ]
  
  
     map_users = [
    {
      userarn  = "arn:aws:iam::288693765212:user/terraformcloud"
      username = "terraformcloud"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::288693765212:user/admin"
      username = "admin"
      groups   = ["system:masters"]
    },
  ]

  map_accounts = [
    "288693765212",
    "291045144839",
  ]

  
  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  #vpc_id = module.vpc.vpc_id
  vpc_id = var.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp3"
  }

##
## Node group 1 - block of two managed worker nodes referencing an external lauch_template.tf file.
##

  node_groups = {
    example = {
      desired_capacity        = 3
      max_capacity            = 15
      min_capacity            = 3
      spot_instance_pools     = 4

      launch_template_id      = aws_launch_template.default.id
      launch_template_version = aws_launch_template.default.default_version

      instance_types = var.instance_types-NG1

      additional_tags = {
        CustomTag = "EKS example"
      }
      # depends_on = [
      #   aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
      #   aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
      #   aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
      # ]  
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

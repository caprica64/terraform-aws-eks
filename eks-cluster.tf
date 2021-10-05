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
## Node group 1
##

  node_groups = {
    example = {
      desired_capacity        = 3
      max_capacity            = 15
      min_capacity            = 3
      spot_instance_pools     = 4
      kubelet_extra_args      = "--node-labels=spot=true"

      launch_template_id      = aws_launch_template.default.id
      launch_template_version = aws_launch_template.default.default_version

      instance_types = var.instance_types-NG1

      additional_tags = {
        CustomTag = "EKS example"
      
      # depends_on = [
      #   aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
      #   aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
      #   aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
      # ]  
        
        
      }
    }

##
## Node group 2
##

    example2 = {
      desired_capacity        = 1
      max_capacity            = 15
      min_capacity            = 1
      spot_instance_pools     = 4

      launch_template_id      = aws_launch_template.secondary.id
      launch_template_version = aws_launch_template.secondary.default_version

      instance_types = var.instance_types-NG2

      additional_tags = {
        CustomTag = "EKS example - secondary"
      
      # depends_on = [
      #   aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
      #   aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
      #   aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
      # ]  
        
        
      }
    }
  }


  # worker_groups = [
  #   {
  #     name                          = "worker-group-1"
  #     instance_type                 = "t3.micro"
  #     additional_userdata           = "echo foo bar"
  #     asg_desired_capacity          = 2
  #     additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
  #   },
  #   {
  #     name                          = "worker-group-2"
  #     instance_type                 = "t2.micro"
  #     additional_userdata           = "echo foo bar"
  #     additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
  #     asg_desired_capacity          = 2
  #   },
  # ]

    # Worker groups (using Launch Templates)
  # worker_groups_launch_template = [
  #   {
  #     name                    = "spot-1"
  #     override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
  #     spot_instance_pools     = 4
  #     asg_max_size            = 5
  #     asg_desired_capacity    = 5
  #     kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
  #     public_ip               = true
  #   },
  # ]
  
}



data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  #subnets         = module.vpc.private_subnets
  subnets         = ["subnet-08ce2d38cc53bb38b","subnet-0637180596a5a8b9d","subnet-0285d4527bbf2ac8e"]
  cluster_enabled_log_types = ["api", "audit", "authenticator", "scheduler", "controllerManager"]


  
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
  
  
  
  node_groups = {
    example = {
      desired_capacity = 3
      max_capacity     = 15
      min_capacity     = 3

      launch_template_id      = aws_launch_template.default.id
      launch_template_version = aws_launch_template.default.default_version

      instance_types = var.instance_types

      additional_tags = {
        CustomTag = "EKS example"
      }
    }
  }
}



data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


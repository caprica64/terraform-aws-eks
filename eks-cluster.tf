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

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.micro"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.micro"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 4
    },
  ]
}


  worker_groups_launch_template = [
    {
      name                 = "bottlerocket-nodes"
      ami_id               = data.aws_ami.bottlerocket_ami.id
      instance_type        = "t3a.small"
      asg_desired_capacity = 2
      key_name             = aws_key_pair.nodes.key_name

      # Since we are using default VPC there is no NAT gateway so we need to
      # attach public ip to nodes so they can reach k8s API server
      # do not repeat this at home (i.e. production)
      public_ip = false

      # This section overrides default userdata template to pass bottlerocket
      # specific user data
      userdata_template_file = "${path.module}/userdata.toml"
      # we are using this section to pass additional arguments for
      # userdata template rendering
      userdata_template_extra_args = {
        enable_admin_container   = false
        enable_control_container = true
        aws_region               = local.region
      }
      # example of k8s/kubelet configuration via additional_userdata
      additional_userdata = <<EOT
[settings.kubernetes.node-labels]
ingress = "allowed"
EOT
    }
  ]


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


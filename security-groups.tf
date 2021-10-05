##
## The following two SG are commented out as example to use but not needed in this lab. They are mainly used when creating the whole VPC within Terraform workspace. Note the vpc_id pointing to the VPC module, unused at this time.
##

# resource "aws_security_group" "worker_group_mgmt_one" {
#   name_prefix = "worker_group_mgmt_one"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
  
#   tags = {
#     Name = "WorkerNode1-MGNT"
#   }  
  
# }

# resource "aws_security_group" "worker_group_mgmt_two" {
#   name_prefix = "worker_group_mgmt_two"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "192.168.0.0/16",
#     ]
#   }

#   tags = {
#   Name = "WorkerNode2-MGNT"
#   }  
  
# }

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  #vpc_id      = module.vpc.vpc_id  ## In this SG we use a previous created VPC so referencing the VPC module is and cannot be used here. We use the variable below to point to a static VPC id.
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
  
  tags = {
    Name = "All-WorkerNodes-MGNT"
  }  
  
}

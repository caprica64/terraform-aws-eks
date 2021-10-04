variable "vpc_id" {
  default = "vpc-037730942b4bae1b8"
  type = string
  description = "VPC from an existant project"
}

variable "region" {
  default = "us-east-1"
  type = string
  description = "AWS Region to use"
}

variable "instance_types" {
  description = "Instance types"
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  type    = list(string)
  default = ["t3.medium"]
}

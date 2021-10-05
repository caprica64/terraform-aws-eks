variable "vpc_id" {
  default = "vpc-0633f54b18096d126"
  type = string
  description = "VPC from an existant project"
}

variable "region" {
  default = "us-east-1"
  type = string
  description = "AWS Region to use"
}

variable "instance_types-NG1" {
  description = "Instance types"
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  type    = list(string)
  default = ["t3.medium"]
}

variable "instance_types-NG2" {
  description = "Instance types"
  # Smallest recommended, where ~1.1Gb of 2Gb memory is available for the Kubernetes pods after ‘warming up’ Docker, Kubelet, and OS
  type    = list(string)
  default = ["t3.small"]
}

variable "kms_arn" {
  default = "arn:aws:kms:us-east-1:288693765212:key/516c693e-4fb2-47d4-b844-0a6c1c0e44b6"
  type = string
  description = "AWS Region to use"
}
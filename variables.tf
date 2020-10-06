variable "name" {
  description = "Name value for resources"
  type        = string
  default     = null
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch EC2 resources in"
  type        = list(string)
  default     = []
}

variable "iam_instance_profile_arn" {
  description = "The IAM Instance Profile ARN to launch EC2 instance with, if not provided a minimal role and corresponding profile will be created"
  type        = string
  default     = null
}

variable "managed_termination_protection" {
  description = "Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens. Valid values are `ENABLED` and `DISABLED`"
  type        = string
  default     = "ENABLED"
}

variable "instance_type" {
  description = "The instance type used by the Auto Scaling group capacity provider"
  type        = string
  default     = "t3.micro"
}

variable "max_size" {
  description = "Max size for the the Auto Scaling group capacity provider"
  type        = number
  default     = 3
}

variable "managed_scaling" {
  description = "Managed scaling configuration for the capacity provider ASG"
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

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

variable "create_capacity_provider" {
  description = "Create an ECS cluster capacity provider."
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "Configuration of one or more capacity providers to associate with the cluster."
  default     = {}
}

variable "cp_managed_termination_protection" {
  description = "Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens. Valid values are `ENABLED` and `DISABLED`"
  type        = string
  default     = "DISABLED"
}

variable "cp_instance_type" {
  description = "The instance type used by the Auto Scaling group capacity provider"
  type        = string
  default     = "t3.micro"
}

variable "cp_min_size" {
  description = "Min size for the the Auto Scaling group capacity provider"
  type        = number
  default     = 1
}

variable "cp_desired_capacity" {
  description = "Desired capacity for the the Auto Scaling group capacity provider"
  type        = number
  default     = 1
}

variable "cp_max_size" {
  description = "Max size for the the Auto Scaling group capacity provider"
  type        = number
  default     = 3
}

variable "cp_managed_scaling" {
  description = "Managed scaling configuration for the capacity provider ASG"
  default     = {}
}

variable "cp_spot" {
  description = "Enable spot instances for the capacity provider ASG"
  type        = bool
  default     = false
}

variable "cp_spot_max_price" {
  description = "Max price for the capacity provider ASG spot instances"
  type        = number
  default     = null
}

variable "cp_weight" {
  description = " The relative percentage of the total number of launched tasks that should use the created capacity provider"
  type        = number
  default     = null
}

variable "cp_base" {
  description = "The number of tasks, at a minimum, to run on the created capacity provider."
  type        = number
  default     = null
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

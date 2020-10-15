variable "name" {
  description = "Name value for resources"
  type        = string
  default     = null
}

variable "create_capacity_provider" {
  description = "Create an ECS cluster capacity provider and associated ASG"
  type        = bool
  default     = false
}

variable "create_cluster" {
  description = "Create the ECS cluster"
  type        = bool
  default     = false
}

variable "create_services" {
  description = "Create a service for each task specified"
  type        = bool
  default     = false
}

variable "services_cluster" {
  description = "ARN of an existing ECS cluster for the services, if omitted and create_cluster is true the new cluster will be used"
  type        = string
  default     = null
}

variable "capacity_providers" {
  description = "List of short names for one or more capacity providers to associate with the cluster, Valid values also include `FARGATE` and `FARGATE_SPOT`"
  default     = []
}

variable "default_capacity_provider_strategies" {
  description = "The default capacity provider strategies to be used by the cluster, strategies cannot contain a mix of capacity providers using Auto Scaling groups and Fargate providers"
  default     = []
}

variable "cp_vpc_zone_identifier" {
  description = "A list of subnet IDs to launch EC2 resources in"
  type        = list(string)
  default     = []
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

variable "cp_associate_public_ip_address" {
  description = "Associate a public IP address with the capacity provider network interface"
  type        = bool
  default     = false
}

variable "cp_security_group_ids" {
  description = "A list of security group IDs to associate the capacity provide with"
  type        = list(string)
  default     = []
}

variable "container_insights" {
  description = "Enable container insights"
  type        = bool
  default     = false
}

variable "tasks" {
  description = "Tasks definitions to be created, values are used to create tasks and accompanying services"
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

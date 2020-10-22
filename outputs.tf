output "cp_arn" {
  description = "The capacity provider ARN"
  value       = var.create_capacity_provider ? aws_ecs_capacity_provider.capacity_provider.0.arn : null
}

output "cp_asg_name" {
  description = "The name of the capacity provider autoscale group"
  value       = var.create_capacity_provider ? module.capacity_provider_asg.0.asg_name : null
}

output "cp_asg_arn" {
  description = "The ARN for the capacity provider autoscaling Group"
  value       = var.create_capacity_provider ? module.capacity_provider_asg.0.asg_arn : null
}

output "cp_lt_arn" {
  description = "The Amazon Resource Name (ARN) of the capacity provider launch template"
  value       = var.create_capacity_provider ? module.capacity_provider_asg.0.lt_arn : null
}

output "cp_lt_id" {
  description = "The ID of the capacity provider launch template"
  value       = var.create_capacity_provider ? module.capacity_provider_asg.0.lt_id : null
}

output "cp_asg_availability_zones" {
  description = "The availability zones of the capacity provider autoscale group"
  value       = var.create_capacity_provider ? module.capacity_provider_asg.0.asg_availability_zones : null
}

output "cp_iam_role_name" {
  description = "The capacity provider instance IAM role name"
  value       = var.create_capacity_provider_role ? aws_iam_role.cp_role.0.name : null
}

output "cp_iam_role_arn" {
  description = "The capacity provider instance IAM role Amazon Resource Name (ARN)"
  value       = var.create_capacity_provider_role ? aws_iam_role.cp_role.0.arn : null
}

output "cluster_arn" {
  description = "The Cluster ARN"
  value       = var.create_cluster ? aws_ecs_cluster.cluster.0.arn : null
}

output "service_arns" {
  description = "The Amazon Resource Names (ARN) that identify the services"
  value       = aws_ecs_service.services.*.id
}

output "service_names" {
  description = "The service names"
  value       = aws_ecs_service.services.*.name
}

output "task_arns" {
  description = "The Amazon Resource Names (ARN) that identify the tasks"
  value       = aws_ecs_task_definition.tasks.*.arn
}

output "task_families" {
  description = "The family of the Task Definitions"
  value       = aws_ecs_task_definition.tasks.*.family
}

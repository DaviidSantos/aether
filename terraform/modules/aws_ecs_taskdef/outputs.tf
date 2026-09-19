output "task_definition_arn" {
  description = "ARN of the created ECS task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "family" {
  description = "Family of the ECS task definition"
  value       = aws_ecs_task_definition.this.family
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_multi_az" {
  description = "Indicates whether Multi-AZ is enabled"
  value       = aws_db_instance.postgres.multi_az
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

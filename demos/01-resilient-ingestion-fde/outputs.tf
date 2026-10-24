output "primary_queue_url" {
  description = "URL of the primary SQS ingestion queue"
  value       = aws_sqs_queue.primary_queue.id
}

output "primary_queue_arn" {
  description = "ARN of the primary SQS ingestion queue"
  value       = aws_sqs_queue.primary_queue.arn
}

output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB persistence table"
  value       = aws_dynamodb_table.events_table.name
}

output "lambda_worker_arn" {
  description = "ARN of the event processing Lambda function"
  value       = aws_lambda_function.worker.arn
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Resilient-Ingestion-Gateway"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Habeeb Olajide"
    }
  }
}

# 1. DynamoDB Persistence Table
resource "aws_dynamodb_table" "events_table" {
  name         = "${var.environment}-ingested-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}

# 2. Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.environment}-ingestion-dlq"
  message_retention_seconds = 1209600 # 14 days retention
  sqs_managed_sse_enabled   = true
}

# 3. Primary Ingestion Queue
resource "aws_sqs_queue" "primary_queue" {
  name                      = "${var.environment}-ingestion-queue"
  message_retention_seconds = 86400 # 1 day retention
  sqs_managed_sse_enabled   = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

# 4. IAM Execution Role for Lambda Worker
resource "aws_iam_role" "worker_role" {
  name = "${var.environment}-ingestion-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "worker_policy" {
  name = "${var.environment}-ingestion-worker-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.primary_queue.arn
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.events_table.arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_worker_policy" {
  role       = aws_iam_role.worker_role.name
  policy_arn = aws_iam_policy.worker_policy.arn
}

# 5. Archive Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

# 6. Lambda Worker Function
resource "aws_lambda_function" "worker" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.environment}-event-ingestion-worker"
  role             = aws_iam_role.worker_role.arn
  handler          = "worker.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.events_table.name
      ENVIRONMENT = var.environment
    }
  }
}

# 7. SQS Event Source Mapping with Partial Batch Failure Reporting
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn                   = aws_sqs_queue.primary_queue.arn
  function_name                      = aws_lambda_function.worker.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 5
  function_response_types            = ["ReportBatchItemFailures"]
}

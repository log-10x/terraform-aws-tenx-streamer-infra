locals {
  tags = merge(var.tenx_streamer_user_supplied_tags, {
    terraform-module         = "tenx-streamer-infra"
    terraform-module-version = "v0.2.1"
    managed-by               = "tenx-terraform"
  })

  # Determine if source and results buckets are the same
  buckets_are_same = var.tenx_streamer_index_source_bucket_name == var.tenx_streamer_index_results_bucket_name

  # Construct the indexWriteContainer path (bucket + path)
  index_write_container = "${var.tenx_streamer_index_results_bucket_name}/${var.tenx_streamer_index_results_path}"
}

resource "aws_sqs_queue" "tenx_index_queue" {
  name = var.tenx_streamer_index_queue_name

  visibility_timeout_seconds = var.tenx_streamer_queue_visibility_timeout
  message_retention_seconds  = var.tenx_streamer_queue_message_retention
  max_message_size           = var.tenx_streamer_queue_max_message_size
  delay_seconds              = var.tenx_streamer_queue_delay_seconds
  receive_wait_time_seconds  = var.tenx_streamer_queue_receive_wait_time

  tags = local.tags
}

resource "aws_sqs_queue" "tenx_query_queue" {
  name = var.tenx_streamer_query_queue_name

  visibility_timeout_seconds = var.tenx_streamer_queue_visibility_timeout
  message_retention_seconds  = var.tenx_streamer_queue_message_retention
  max_message_size           = var.tenx_streamer_queue_max_message_size
  delay_seconds              = var.tenx_streamer_queue_delay_seconds
  receive_wait_time_seconds  = var.tenx_streamer_queue_receive_wait_time

  tags = local.tags
}

resource "aws_sqs_queue" "tenx_pipeline_queue" {
  name = var.tenx_streamer_pipeline_queue_name

  visibility_timeout_seconds = var.tenx_streamer_queue_visibility_timeout
  message_retention_seconds  = var.tenx_streamer_queue_message_retention
  max_message_size           = var.tenx_streamer_queue_max_message_size
  delay_seconds              = var.tenx_streamer_queue_delay_seconds
  receive_wait_time_seconds  = var.tenx_streamer_queue_receive_wait_time

  tags = local.tags
}

# S3 Buckets for Indexing
resource "aws_s3_bucket" "index_source" {
  count  = var.tenx_streamer_create_index_source_bucket ? 1 : 0
  bucket = var.tenx_streamer_index_source_bucket_name

  tags = local.tags
}

resource "aws_s3_bucket" "index_results" {
  count  = var.tenx_streamer_create_index_results_bucket && !local.buckets_are_same ? 1 : 0
  bucket = var.tenx_streamer_index_results_bucket_name

  tags = local.tags
}

# SQS Queue Policy to allow S3 to send messages
resource "aws_sqs_queue_policy" "index_queue_s3_policy" {
  queue_url = aws_sqs_queue.tenx_index_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ToSendMessage"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.tenx_index_queue.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${var.tenx_streamer_index_source_bucket_name}"
          }
        }
      }
    ]
  })
}

# S3 Bucket Notification to send events directly to SQS
resource "aws_s3_bucket_notification" "index_trigger" {
  count  = var.tenx_streamer_create_index_source_bucket ? 1 : 0
  bucket = aws_s3_bucket.index_source[0].id

  queue {
    queue_arn     = aws_sqs_queue.tenx_index_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.tenx_streamer_index_trigger_prefix
    filter_suffix = var.tenx_streamer_index_trigger_suffix
  }

  depends_on = [aws_sqs_queue_policy.index_queue_s3_policy]
}

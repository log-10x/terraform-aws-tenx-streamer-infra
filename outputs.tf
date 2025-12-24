# SQS Queue URLs - used by application configuration
output "index_queue_url" {
  description = "The URL of the index SQS queue (for tenx.quarkus.index.queue.url)"
  value       = aws_sqs_queue.tenx_index_queue.url
}

output "query_queue_url" {
  description = "The URL of the query SQS queue (for tenx.quarkus.query.queue.url)"
  value       = aws_sqs_queue.tenx_query_queue.url
}

output "subquery_queue_url" {
  description = "The URL of the sub-query SQS queue (for tenx.quarkus.subquery.queue.url)"
  value       = aws_sqs_queue.tenx_subquery_queue.url
}

output "stream_queue_url" {
  description = "The URL of the stream SQS queue (for tenx.quarkus.stream.queue.url)"
  value       = aws_sqs_queue.tenx_stream_queue.url
}

# S3 Bucket Names - used for application configuration and reference
output "index_source_bucket_name" {
  description = "The name of the S3 bucket for source files to be indexed"
  value       = var.tenx_streamer_index_source_bucket_name
}

output "index_results_bucket_name" {
  description = "The name of the S3 bucket for indexing results"
  value       = var.tenx_streamer_index_results_bucket_name
}

output "index_write_container" {
  description = "The full path for indexing results (bucket + path) - used for tenx.quarkus.index.write.container"
  value       = local.index_write_container
}

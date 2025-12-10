# Production Example - Custom Configuration
# This example shows a production-ready configuration with:
# - Custom queue names
# - Separate buckets for source and results
# - Extended message retention
# - Production tags

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "tenx_streamer_infra" {
  source  = "log-10x/tenx-streamer-infra/aws"
  version = "~> 0.1"

  # Custom queue names
  tenx_streamer_index_queue_name    = "prod-tenx-index-queue"
  tenx_streamer_query_queue_name    = "prod-tenx-query-queue"
  tenx_streamer_pipeline_queue_name = "prod-tenx-pipeline-queue"

  # Queue configuration for production
  tenx_streamer_queue_visibility_timeout = 60       # 1 minute
  tenx_streamer_queue_message_retention  = 1209600  # 14 days
  tenx_streamer_queue_receive_wait_time  = 20       # Long polling

  # S3 configuration - separate buckets for source and results
  tenx_streamer_index_source_bucket_name  = "prod-logs-bucket"
  tenx_streamer_index_results_bucket_name = "prod-index-results-bucket"
  tenx_streamer_index_results_path        = "indexed/"

  # Trigger indexing only for JSON logs in the logs/ directory
  tenx_streamer_index_trigger_prefix = "logs/"
  tenx_streamer_index_trigger_suffix = ".json"

  # Production tags
  tenx_streamer_user_supplied_tags = {
    Environment = "production"
    Project     = "10x-streamer"
    ManagedBy   = "terraform"
    Team        = "data-engineering"
    CostCenter  = "engineering"
  }
}

# Outputs for application configuration
output "queue_urls" {
  description = "All queue URLs for Quarkus configuration"
  value = {
    index    = module.tenx_streamer_infra.index_queue_url
    query    = module.tenx_streamer_infra.query_queue_url
    pipeline = module.tenx_streamer_infra.pipeline_queue_url
  }
}

output "index_write_container" {
  description = "Index write container for Quarkus configuration"
  value       = module.tenx_streamer_infra.index_write_container
}

output "bucket_names" {
  description = "S3 bucket names"
  value = {
    source  = module.tenx_streamer_infra.index_source_bucket_name
    results = module.tenx_streamer_infra.index_results_bucket_name
  }
}

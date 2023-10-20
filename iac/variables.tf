variable "localstack" {
  description = "set to true when running under local stack"
  type        = bool
  default     = true
}

variable "app_name_prefix" {
  description = "Application name prefix"
  type        = string
  default     = "app"
}

variable "stack_suffix" {
  description = "suffix to make stack name unique"
  type        = string
  default     = "local"
}

variable "aws_region_primary" {
  description = "AWS primary region"
  type        = string
  default     = "us-east-1"
}

variable "stage_name" {
  description = "Stage name. Example prod,dev,staging"
  type        = string
  default     = "dev"
}

variable "lambda_architectures" {
  description = "Lambda architecture. arm64 or x86_64"
  type        = string
  default     = "x86_64"
}

variable "lambda_src_base" {
  description = "Base folder for lambda source code"
  type        = string
  default     = "../src"
}

variable "vpc_id" {
  description = "VPC id if using private api / lambda"
  type        = string
}

variable "lambda_security_group_ids" {
  description = "vpc config security_group_ids"
  type        = list(string)
  default     = []
}

variable "lambda_subnet_ids" {
  description = "vpc config subnet_ids"
  type        = list(string)
  default     = []
}

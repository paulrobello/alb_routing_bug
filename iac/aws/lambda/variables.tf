variable "localstack" {
  description = "set to true when running under local stack"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the lambda."
  type        = string
}

variable "output_path" {
  description = "Location for lambda payload zip file. Example ../zip/my_lambda.zip"
  type        = string
}

variable "handler" {
  description = "Lambda handler."
  type        = string
  default     = "handler.lambda_handler"
}

variable "timeout" {
  description = "Timeout in seconds for lambda run"
  type        = number
  default     = 30
}

variable "security_group_ids" {
  description = "vpc config security_group_ids"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "vpc config subnet_ids"
  type        = list(string)
  default     = []
}

variable "memory_size" {
  description = "Memory size for lambda in MB"
  type        = number
  default     = 128
}

variable "publish" {
  description = "Publish version of function"
  type        = bool
  default     = false
}

variable "architectures" {
  description = "Lambda architecture. arm64 or x86_64"
  type        = string
  default     = "x86_64"
}

variable "runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.11"
}

variable "aws_region_primary" {
  type = string
}

variable "environment" {
  description = "Environment vars to pass to lambda."
  default     = {}
}

variable "log_retention_in_days" {
  description = "Lambda log retention period in days"
  type        = number
  default     = 3
}

variable "lambda_tracing_mode" {
  description = "Lambda tracing mode. PassThrough or Active"
  type        = string
  default     = "PassThrough"
}

variable "layers" {
  description = "List of layer arn's to add to lambda"
  type        = list(string)
  default     = []
}

# Define a variable for the Lambda Power Tools layer ARN
locals {
  lambda_power_tools_layer_arn = "arn:aws:lambda:${var.aws_region_primary}:017000801446:layer:AWSLambdaPowertoolsPythonV2${var.architectures == "arm64" ? "-Arm64" : ""}:45"
}

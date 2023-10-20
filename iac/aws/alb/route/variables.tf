variable "localstack" {
  description = "set to true when running under local stack"
  type        = bool
}


variable "name" {
  description = "Route name"
  type        = string
}

variable "stage_name" {
  description = "Stage name. Example prod,dev,staging"
  type        = string
}

variable "priority" {
  description = "Rule priority. defaults to auto assign."
  type        = number
  default     = null
}

variable "alb_listener_arn" {
  description = "ALB Listener ARN"
  type        = string
}

variable "api_key" {
  description = "API key to access route"
  type        = string
}

variable "lambda_arn" {
  description = "Lambda target ARN"
  type        = string
}

variable "lambda_function_name" {
  description = "Target lambda function name"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}

variable "routes" {
  description = "Route paths"
  type        = list(string)
}

variable "http_methods" {
  description = "Allowed HTTP methods. GET, POST etc..."
  type        = list(string)
}

output "name" {
  description = "Lambda name"
  value = var.name
}

output "lambda_role" {
  description = "Lambda execution role"
  value = aws_iam_role.lambda_role
}

output "lambda" {
  description = "Lambda function"
  value = aws_lambda_function.lambda
}
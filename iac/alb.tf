resource "random_string" "api_key" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow http inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name                       = "alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = var.lambda_subnet_ids
  enable_deletion_protection = false
  enable_http2               = false
  drop_invalid_header_fields = true
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_tg.arn # 404 lambda
  }
}


resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.alb_listener.arn

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HEALTHY"
      status_code  = "200"
    }
  }

#  condition {
#    query_string {
#      key   = "health"
#      value = "check"
#    }
##    query_string {
##      value = "bar"
##    }
#  }

  condition {
    path_pattern {
      values = ["/${var.stage_name}/health"]
    }
  }
  condition {
    http_header {
      http_header_name = "x-api-key"
      values           = [random_string.api_key.result]
    }
  }
}


#------- 404 for default route --------

resource "aws_lb_target_group" "default_tg" {
  name        = "alb-tg-default"
  target_type = "lambda"
}

module "lambda_404" {
  source             = "./aws/lambda/"
  name               = "route_404"
  output_path        = "${var.lambda_src_base}/lambda_route/lambda_route.zip"
  aws_region_primary = var.aws_region_primary
  architectures      = var.lambda_architectures
  localstack         = var.localstack
  security_group_ids = var.lambda_security_group_ids
  subnet_ids         = var.lambda_subnet_ids
  environment        = {
    RETURN_CODE = "404",
    MESSAGE     = "404 not found"
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.default_tg.arn
  target_id        = module.lambda_404.lambda.arn
  depends_on       = [aws_lambda_permission.allow_alb]
}

resource "aws_lambda_permission" "allow_alb" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_404.lambda.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.default_tg.arn
}

#-------- test routes ------------

module "lambda_route1" {
  source             = "./aws/lambda/"
  name               = "route1"
  output_path        = "${var.lambda_src_base}/lambda_route/lambda_route.zip"
  aws_region_primary = var.aws_region_primary
  architectures      = var.lambda_architectures
  localstack         = var.localstack
  security_group_ids = var.lambda_security_group_ids
  subnet_ids         = var.lambda_subnet_ids
  environment        = {
    RETURN_CODE = "200",
    MESSAGE     = "Route1"
  }
}

module "route1" {
  source               = "./aws/alb/route"
  localstack           = var.localstack
  name                 = "route1"
  alb_arn              = aws_lb.alb.arn
  alb_listener_arn     = aws_lb_listener.alb_listener.arn
  stage_name           = var.stage_name
  http_methods         = ["GET"]
  lambda_arn           = module.lambda_route1.lambda.arn
  lambda_function_name = module.lambda_route1.lambda.function_name
  routes               = ["/route1", "/route1/"]
  priority             = 10
  api_key              = random_string.api_key.result
}

module "lambda_route2" {
  source             = "./aws/lambda/"
  name               = "route2"
  output_path        = "${var.lambda_src_base}/lambda_route/lambda_route.zip"
  aws_region_primary = var.aws_region_primary
  architectures      = var.lambda_architectures
  localstack         = var.localstack
  security_group_ids = var.lambda_security_group_ids
  subnet_ids         = var.lambda_subnet_ids
  environment        = {
    RETURN_CODE = "200",
    MESSAGE     = "Route2"
  }
}

module "route2" {
  source               = "./aws/alb/route"
  localstack           = var.localstack
  name                 = "route2"
  alb_arn              = aws_lb.alb.arn
  alb_listener_arn     = aws_lb_listener.alb_listener.arn
  stage_name           = var.stage_name
  http_methods         = ["GET"]
  lambda_arn           = module.lambda_route2.lambda.arn
  lambda_function_name = module.lambda_route2.lambda.function_name
  routes               = ["/route2", "/route2/"]
  api_key              = random_string.api_key.result
  priority             = 20
}

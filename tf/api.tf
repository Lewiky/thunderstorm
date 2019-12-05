resource "aws_api_gateway_rest_api" "api" {
  name        = "api-gateway"
  description = "Handles requests to call lambda function"
}

#Resources
resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "start"
}

resource "aws_api_gateway_resource" "api_resource_kill" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "kill"
}
resource "aws_api_gateway_resource" "api_resource_output" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "output"
}

#Methods

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.api_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_method_kill" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.api_resource_kill.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "api_method_output" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.api_resource_output.id}"
  http_method   = "GET"
  authorization = "NONE"
}

#Lambda Integrations

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "${aws_api_gateway_method.api_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.input_lambda_function.invoke_arn}"
}

resource "aws_api_gateway_integration" "lambda_kill_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource_kill.id}"
  http_method = "${aws_api_gateway_method.api_method_kill.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.kill_lambda_function.invoke_arn}"
}

resource "aws_api_gateway_integration" "lambda_output_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource_output.id}"
  http_method = "${aws_api_gateway_method.api_method_output.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.output_lambda_function.invoke_arn}"
}

#Deployment/Stage

resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda_integration",
    "aws_api_gateway_integration.lambda_kill_integration",
    "aws_api_gateway_integration.lambda_output_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "main"
}

#Output the URL of the deployment to the console
output "base_url" {
  value = "${aws_api_gateway_deployment.api-deployment.invoke_url}"
}

#Enable logging for all methods
resource "aws_api_gateway_method_settings" "general_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_deployment.api-deployment.stage_name}"
  method_path = "*/*"
  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}
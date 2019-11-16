resource "aws_api_gateway_rest_api" "api" {
  name = "api-gateway"
  description = "Handles requests to call lambda function"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id  = "${aws_api_gateway_rest_api.api.id}"
  parent_id    = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part    = "{proxy+}"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.api_resource.id}"
  http_method = "${aws_api_gateway_method.api_method.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri  = "${aws_lambda_function.input_lambda_function.invoke_arn}"

}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}" 
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.input_lambda_function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda_integration",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "test"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.api-deployment.invoke_url}"
}
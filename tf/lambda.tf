resource "aws_lambda_function" "input_lambda_function" {
  function_name = "Input_Function"

  s3_bucket = "nonce-cloud-lambda-storage"
  s3_key    = "latest/deployment.zip"

  handler = "input.request_handler"
  runtime = "python3.6"

  timeout = 60

  role = "${aws_iam_role.lambda_exec.arn}"

  environment {
    variables = {
      SQS_INPUT_QUEUE_NAME  = aws_sqs_queue.nonce-input-queue.name,
      ECS_CLUSTER_NAME      = aws_ecs_cluster.main.name,
      NONCE_TASK_DEFINITION = aws_ecs_task_definition.app.family,
    }
  }
}

resource "aws_lambda_function" "kill_lambda_function" {
  function_name = "Kill_Function"

  s3_bucket = "nonce-cloud-lambda-storage"
  s3_key    = "latest/deployment-kill.zip"

  handler = "kill.request_handler"
  runtime = "python3.6"

  role = "${aws_iam_role.lambda_exec.arn}"

  timeout = 60

  environment {
    variables = {
      SQS_INPUT_QUEUE      = aws_sqs_queue.nonce-input-queue.name,
      SQS_OUTPUT_QUEUE     = aws_sqs_queue.nonce-output-queue.name,
      ECS_CLUSTER_NAME     = aws_ecs_cluster.main.name,
      ECS_TASK_FAMILY_NAME = aws_ecs_task_definition.app.family
    }
  }
}

resource "aws_lambda_function" "output_lambda_function" {
  function_name = "Output_Function"

  s3_bucket = "nonce-cloud-lambda-storage"
  s3_key    = "latest/output.zip"

  handler = "output.request_handler"
  runtime = "python3.6"

  role = "${aws_iam_role.lambda_exec.arn}"

  timeout = 60

  environment {
    variables = {
      SQS_OUTPUT_QUEUE = aws_sqs_queue.nonce-output-queue.name,
    }
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.input_lambda_function.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_kill" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.kill_lambda_function.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

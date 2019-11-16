# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "nonce_log_group" {
  name              = "/ecs/nonce-app"
  retention_in_days = 30

  tags = {
    Name = "nonce-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "nonce_log_stream" {
  name           = "nonce-log-stream"
  log_group_name = aws_cloudwatch_log_group.nonce_log_group.name
}
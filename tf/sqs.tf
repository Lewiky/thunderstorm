resource "aws_sqs_queue" "nonce-input-queue" {
    name  = "cloud_nonce-input-queue"
}

resource "aws_sqs_queue" "nonce-output-queue" {
    name  = "cloud_nonce-output-queue"
}

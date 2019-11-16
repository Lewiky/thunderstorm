resource "aws_ecs_cluster" "main" {
    name = "nonce-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "nonce-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = templatefile("./templates/nonce-app.json.tpl", 
    {
        app_image      = var.app_image
        app_port       = var.app_port
        fargate_cpu    = var.fargate_cpu
        fargate_memory = var.fargate_memory
        aws_region     = var.region
        input_queue    = aws_sqs_queue.nonce-input-queue.name
        output_queue   = aws_sqs_queue.nonce-output-queue.name
    })
}

resource "aws_ecs_service" "main" {
  name            = "nonce-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = aws_subnet.private.*.id
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}
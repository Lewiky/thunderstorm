[
  {
    "name": "nonce-app",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nonce-app",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "environment" : [
        {"name": "SQS_INPUT_QUEUE_NAME", "value": "${input_queue}"},
        {"name": "SQS_OUTPUT_QUEUE_NAME", "value": "${output_queue}"} 
    ]
  }
]
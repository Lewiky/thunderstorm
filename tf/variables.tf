variable "region" {
  default = "us-east-1"
}

variable "bucket" {
  default = "thunderstorm-cloud-lambda-storage"
}

variable "app_image" {
  default = "535653969087.dkr.ecr.us-east-1.amazonaws.com/cloud-computing/nonce"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "cloud_ecs_task_execution_role"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default     = "cloud_ecs_auto_scale_role"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "1"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 0
}


variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Talks to the local Docker engine through its default socket.
provider "docker" {}

variable "container_name" {
  description = "Name of the Docker container"
  type        = string
  default     = "terraform-nginx"
}

variable "external_port" {
  description = "Port on the host that maps to port 80 in the container"
  type        = number
  default     = 8081
}

# Pull the nginx image.
resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = false
}

# Create a container from that image. Terraform creates the image first
# because the container refers to docker_image.nginx (resource dependency).
resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.external_port
  }
}

output "container_name" {
  value = docker_container.nginx.name
}

output "url" {
  value = "http://localhost:${var.external_port}"
}
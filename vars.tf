variable "project_id" {
  type = string
}

variable "project_nmr" {
  type = number
}

variable "project_default_region" {
  type    = string
  default = "europe-west1"
}

variable "topic_id" {
  type = string
}

variable "run_service_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "default_run_image" {
  type    = string
  default = "nginx:latest"
}
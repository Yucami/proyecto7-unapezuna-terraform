variable "aws_region" {
  description = "Región AWS principal"
  type        = string
  default     = "us-east-1"
}

variable "resend_api_key" {
  description = "API Key de Resend para envío de emails"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Prefijo del proyecto"
  type        = string
  default     = "unapezuna"
}

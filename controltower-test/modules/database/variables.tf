variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Aurora DB subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for Aurora cluster"
  type        = string
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
}

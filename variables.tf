variable "region" {
  type    = string
  default = "us-east-1"
}
variable "account_id" {
  type    = number
  default = 123456789012
}

variable "tag_environment" {
  type    = string
  default = "dev"
}

variable "tag_project" {
  type    = string
  default = "my-tf-project"
}
variable "lambda_runtime" {
  type    = string
  default = "nodejs20.x"
}
variable "lambda_timeout" {
  type    = number
  default = 30
}
variable "claim_function_name" {
  type    = string
  default = "claimFunction"
}
variable "create_function_name" {
  type    = string
  default = "create"
}
variable "stage_name" {
  type    = string
  default = "dev"
}

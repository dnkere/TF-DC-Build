variable "region" {
  description = "The region where this terraform is executed."
  type        = string
}

# staging
variable "stage" {
  description = "Stage of application."
  type        = string

  validation {
    condition     = var.stage == "dev" || var.stage == "qa" || var.stage == "prod"
    error_message = "Stage variable must be one of (dev, qa, prod)."
  }
}

# Slack
variable "slack_verification_token" {
  description = "Slack Verification Token"
}
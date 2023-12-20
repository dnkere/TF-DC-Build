resource "aws_ssm_parameter" "slack_verification_token" {
  name        = "slack_verification_token"
  description = "Encrypted Slack Token"
  type        = "SecureString"
  value       = var.slack_verification_token
  key_id      = aws_kms_key.slash_echo_kms.id
}
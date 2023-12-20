# KMS
resource "aws_kms_key" "slash_echo_kms" {
    description = "KMS key used to encrypt Slack secrets"
    policy = <<-EOF
    {
      "Id": "key-consolepolicy-3",
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Enable IAM User Permissions",
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "${data.aws_caller_identity.current.arn}"
            ]
          },
          "Action": "kms:*",
          "Resource": "*"
        },
        {
          "Sid": "Allow access for Key Administrators",
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "${data.aws_caller_identity.current.arn}"
            ]
          },
          "Action": [
            "kms:Create*",
            "kms:Describe*",
            "kms:Enable*",
            "kms:List*",
            "kms:Put*",
            "kms:Update*",
            "kms:Revoke*",
            "kms:Disable*",
            "kms:Get*",
            "kms:Delete*",
            "kms:TagResource",
            "kms:UntagResource",
            "kms:ScheduleKeyDeletion",
            "kms:CancelKeyDeletion"
          ],
          "Resource": "*"
        },
        {
          "Sid": "Allow use of the key",
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "${aws_iam_role.iam_lambda_slash_echo.arn}"
            ]
          },
          "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ],
          "Resource": "*"
        },
        {
          "Sid": "Allow attachment of persistent resources",
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "${aws_iam_role.iam_lambda_slash_echo.arn}"
            ]
          },
          "Action": [
            "kms:CreateGrant",
            "kms:ListGrants",
            "kms:RevokeGrant"
          ],
          "Resource": "*",
          "Condition": {
            "Bool": {
                "kms:GrantIsForAWSResource": "true"
            }
          }
        }
      ]
    }
    EOF
}
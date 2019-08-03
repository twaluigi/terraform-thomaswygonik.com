resource "aws_iam_policy" "ci_s3_site_policy" {
  provider    = "aws.site_account"
  name        = "ci_s3_site_policy"
  description = "Allow CI tools to modify contents in website bucket"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.site_bucket.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.site_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "ci_s3_site_role" {
  provider = "aws.site_account"
  name = "ci_s3_site_role"
  description = "Allow specific Principals to assume this role"
  assume_role_policy = <<TRUST
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": ["${var.ci_user_arn}"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
TRUST
}

resource "aws_iam_role_policy_attachment" "ci_s3_site_role_policy_attach" {
  role       = "${aws_iam_role.ci_s3_site_role.arn}"
  policy_arn = "${aws_iam_policy.ci_s3_site_policy.arn}"
}
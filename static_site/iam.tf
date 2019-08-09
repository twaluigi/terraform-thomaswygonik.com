data "template_file" "ci_s3_site_policy" {
  template = "${file("${path.module}/policies/ci_s3_site_policy.json")}"
  vars = {
    bucket_arn = "${aws_s3_bucket.site_bucket.arn}"
  }
}

data "template_file" "ci_s3_site_role_trust" {
  template = "${file("${path.module}/policies/trust_policies/allow_assume_ci_site_role_trust.json")}"
  vars = {
    ci_user_arn = "${var.ci_user_arn}"
  }
}

data "template_file" "ci_s3_allow_assume_role" {
  template = "${file("${path.module}/policies/allow_assume_ci_site_role.json")}"
  vars = {
    ci_s3_site_role = "${aws_iam_role.ci_s3_site_role.arn}"
  }
}

resource "aws_iam_policy" "ci_s3_site_policy" {
  provider    = "aws.site_account"
  name        = "ci_s3_site_policy"
  description = "Allow CI tools to modify contents in website bucket"
  policy      = "${data.template_file.ci_s3_site_policy.rendered}"
}

resource "aws_iam_role" "ci_s3_site_role" {
  provider    = "aws.site_account"
  name        = "ci_s3_site_role"
  description = "Allow specific Principals to assume this role"
  tags = {
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
  assume_role_policy = "${data.template_file.ci_s3_site_role_trust.rendered}"
}

resource "aws_iam_role_policy_attachment" "ci_s3_site_role_policy_attach" {
  provider   = "aws.site_account"
  role       = "${aws_iam_role.ci_s3_site_role.name}"
  policy_arn = "${aws_iam_policy.ci_s3_site_policy.arn}"
}

resource "aws_iam_policy" "allow_assume_ci_site_role" {
  provider = "aws.site_account"
  policy   = "${data.template_file.ci_s3_allow_assume_role.rendered}"
}
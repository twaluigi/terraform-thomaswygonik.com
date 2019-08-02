resource "aws_codepipeline" "site-pipeline" {
  provider = "aws.site_account"
  name     = "${var.short-site-name}_pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline_artifacts.bucket}"
    type     = "S3"

    encryption_key {
      id   = "${data.aws_kms_alias.s3kmskey.arn}"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["${var.short-site-name}-source-artifacts"]

      configuration = {
        OAuthToken           = "${var.github-oauth-token}"
        Owner                = "${var.github-owner}"
        Repo                 = "${var.github-repo}"
        Branch               = "${var.github-branch}"
        PollForSourceChanges = "${var.poll-source-changes}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["${var.short-site-name}-source-artifacts"]
      version         = "1"

      configuration = {
        ProjectName = "${var.short-site-name}_build"
      }
    }
  }
}


resource "aws_codebuild_project" "site-build" {
  provider = "aws.site_account"
  name          = "${var.short-site-name}_build"
  description   = "${var.site-name} build site"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_cache.bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/ruby:2.5.3"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "SITE_NAME"
      value = "${aws_s3_bucket.site.id}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = {
    Name        = "CodeBuild-${var.site-name}"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

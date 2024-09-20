
/* CodeBuild Projects */
/* Build stage */
resource "aws_codebuild_project" "build_stage" {
  name          = "build_stage"
  description   = "Build stage for Next.js app"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "public.ecr.aws/sam/build-nodejs18.x:latest"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/buildspec-build.yml")
  }
}

/* Test stage */
resource "aws_codebuild_project" "test_stage" {
  name          = "test_stage"
  description   = "Test stage for Next.js app"
  service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/buildspec-test.yml")
  }
}


/* CodePipeline */
resource "aws_codepipeline" "cicd_pipeline" {
  name     = "tf-cicd"
  role_arn = aws_iam_role.tf-codepipeline-role.arn

  artifact_store {
    type     = "S3"
    location = module.s3_bucket.s3_bucket_id
  }

  /* Source stage */
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source-output"]
      configuration = {
        FullRepositoryId    = "GivenCingco/nextjs-blog-bitcube"
        BranchName          = "main"
        ConnectionArn       = var.codestart_connector_cred
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  /* Build stage */
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["source-output"]
      output_artifacts = ["build-output"]
      configuration = {
        ProjectName = aws_codebuild_project.build_stage.name
      }
    }
  }

  /* Test stage */
  stage {
    name = "Test"
    action {
      name             = "Test"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["build-output"]
      configuration = {
        ProjectName = aws_codebuild_project.test_stage.name
      }
    }
  }

  /* Deploy stage */
  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      provider         = "CodeDeploy"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["build-output"]
      configuration = {
        ApplicationName     = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
      }
    }
  }
}
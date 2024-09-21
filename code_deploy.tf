/* CodeDeploy Application */
resource "aws_codedeploy_app" "app" {
  name = "nextjs-app"
}

/* CodeDeploy Deployment group */
resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "nextjs-deployment-group"
  service_role_arn      = aws_iam_role.tf-codedeploy-role.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "elasticbeanstalk:environment-name"  # This key identifies the environment
      type  = "KEY_AND_VALUE"
      value = aws_elastic_beanstalk_environment.env.name  # Ensure this matches your environment's name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}


/* CodeDeploy Deployment */
resource "aws_codedeploy_deployment" "deployment" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = aws_codedeploy_deployment_group.deployment_group_name

  // Specify the S3 bucket and key where your application ZIP file is located
  revision {
    revision_type = "S3"
    s3_location {
      bucket     = module.s3_bucket.s3_bucket_id  // Replace with your S3 bucket name
      key        = "my-nextjs-app.zip"  // Path to your ZIP file in S3
      bundle_type = "zip"
    }
  }
}

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
}
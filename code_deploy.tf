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

output "deployment_group_name" {
  value = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
}
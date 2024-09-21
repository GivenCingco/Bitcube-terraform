resource "aws_elastic_beanstalk_application" "app" {
  name        = "nextjs-app"
  description = "Nextjs app"
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "nextjs-app-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2 v5.9.6 running Node.js 18"

  # Add the instance profile created above
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.elastic_beanstalk_instance_profile.name
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "3"
  }
    setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"  # Replace with your desired instance type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = module.eb_sg.security_group_id # Replace with your desired instance type
  }

   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "VPCId"
    value     = module.vpc.vpc_id  # Replace with your desired instance type
  }

   setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "Subnets"
    value     = join(",", module.vpc.public_subnets)  # Replace with your desired instance type
  }

}
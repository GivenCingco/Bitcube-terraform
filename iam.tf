/*================== CodePipeline============== */

/* CodePipeline IAM Role */
resource "aws_iam_role" "tf-codepipeline-role" {
  name = "tf-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

/* CodePipeline IAM Policies */
data "aws_iam_policy_document" "tf-cicd-pipeline-policies" {
  statement {
    sid      = ""
    actions  = ["codestar-connections:UseConnection"]
    resources = ["*"]
    effect   = "Allow"
  }

  statement {
    sid      = ""
    actions  = ["cloudwatch:*", "s3:*", "codebuild:*", "kms:Decrypt"]
    resources = ["*"]
    effect   = "Allow"
  }
}

/* Attach Policy to CodePipeline Role */
resource "aws_iam_policy" "tf-cicd-pipeline-policy" {
  name        = "tf-cicd-pipeline-policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.tf-cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-pipeline-attachment" {
  policy_arn = aws_iam_policy.tf-cicd-pipeline-policy.arn
  role       = aws_iam_role.tf-codepipeline-role.id
}



/*================== CodeBuild============== */

/* CodeBuild IAM Role */
resource "aws_iam_role" "tf-codebuild-role" {
  name = "tf-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

/* CodeBuild IAM Policies */
data "aws_iam_policy_document" "tf-cicd-build-policies" {
  statement {
    sid      = ""
    actions  = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*", "iam:*", "kms:Decrypt"]
    resources = ["*"]
    effect   = "Allow"
  }
}

/* Attach CodeBuild Policy */
resource "aws_iam_policy" "tf-cicd-build-policy" {
  name        = "tf-cicd-build-policy"
  path        = "/"
  description = "Codebuild policy"
  policy      = data.aws_iam_policy_document.tf-cicd-build-policies.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment1" {
  policy_arn = aws_iam_policy.tf-cicd-build-policy.arn
  role       = aws_iam_role.tf-codebuild-role.id
}

/* Attach AWS PowerUserAccess Policy to CodeBuild Role */
resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = aws_iam_role.tf-codebuild-role.id
}


/*================== CodeDeploy============== */

/*AWS CodeDeploy Role*/
resource "aws_iam_role" "tf-codedeploy-role" {
  name = "tf-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}


/* CodeDeploy Policy*/
resource "aws_iam_role_policy" "codedeploy_custom_policy" {
  name = "CodeDeployCustomPolicy"
  role = aws_iam_role.tf-codedeploy-role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticbeanstalk:DescribeEnvironments",
          "elasticbeanstalk:DescribeEvents",
          "elasticbeanstalk:UpdateEnvironment",
          "elasticbeanstalk:TerminateEnvironment",
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "cloudwatch:PutMetricData",
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "autoscaling:DescribeAutoScalingGroups"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetDeployment",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:StopDeployment",
          "codedeploy:BatchGetApplications",
          "codedeploy:BatchGetDeployments",
          "codedeploy:BatchGetDeploymentInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

/* Attach AWS Managed Policy for Elastic Beanstalk deployments */
resource "aws_iam_role_policy_attachment" "codedeploy-policy-attachment" {
  role       = aws_iam_role.tf-codedeploy-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

/* =========Elastic Beanstalk ==========*/
# Create an IAM role for Elastic Beanstalk
resource "aws_iam_role" "elastic_beanstalk_instance_role" {
  name = "elastic_beanstalk_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the Elastic Beanstalk Managed Policy to the Role
resource "aws_iam_role_policy_attachment" "beanstalk_managed_policy" {
  role       = aws_iam_role.elastic_beanstalk_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

# Optionally attach an additional policy if required for extra services
resource "aws_iam_role_policy_attachment" "beanstalk_additional_policy" {
  role       = aws_iam_role.elastic_beanstalk_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"  # Example for S3 access
}

# Create an IAM Instance Profile for Elastic Beanstalk
resource "aws_iam_instance_profile" "elastic_beanstalk_instance_profile" {
  name = "elastic_beanstalk_instance_profile"
  role = aws_iam_role.elastic_beanstalk_instance_role.name
}
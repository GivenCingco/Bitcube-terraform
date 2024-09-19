variable "dockerhub_cred" {
  type = string
  default = "arn:aws:secretsmanager:us-east-1:009160050878:secret:codebuild/dockerhub-bh0WqA"
  description = "Variable for DockerHub credentials"
}

variable "codestart_connector_cred" {
  type = string
  default = "arn:aws:codeconnections:us-east-1:009160050878:connection/0ea54640-35fd-4696-a116-e6b9b0623370"
  description = "Variable for CodeStar connection credentials"

}
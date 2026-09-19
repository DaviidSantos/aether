module "backend_ecr_repository" {
  source = "./modules/aws_ecr_repository"

  name = var.backend_ecr_repository_name
}

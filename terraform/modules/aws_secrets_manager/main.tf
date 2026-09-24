resource "aws_secretsmanager_secret" "this" {
  name        = var.secret_name
  description = var.description

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret
}

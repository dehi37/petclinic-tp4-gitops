################################################################################
# Module IAM – Rôles en moindre privilège pour ECS & OIDC GitHub
# Aucune clé d'accès statique – authentification sécurisée uniquement
################################################################################

data "aws_caller_identity" "current" {}

# ── Rôle d'exécution ECS (pull image ECR, écriture logs, lecture secrets) ────
resource "aws_iam_role" "ecs_execution" {
  name = "${var.name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "${var.name_prefix}-ecs-execution-role" }
}

# Politique AWS gérée de base pour ECS
resource "aws_iam_role_policy_attachment" "ecs_execution_base" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Politique custom : lecture du secret Secrets Manager + écriture logs
resource "aws_iam_role_policy" "ecs_execution_custom" {
  name = "${var.name_prefix}-ecs-execution-custom"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadDBSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [var.db_secret_arn]
      },
      {
        Sid    = "PullFromECR"
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken"
        ]
        Resource = [var.ecr_repository_arn, "*"]
      },
      {
        Sid    = "WriteLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["${var.log_group_arn}:*"]
      }
    ]
  })
}

# ── Rôle de tâche ECS (permissions applicatives) ──────────────────────────────
resource "aws_iam_role" "ecs_task" {
  name = "${var.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "${var.name_prefix}-ecs-task-role" }
}

# Politique applicative : accès au secret uniquement (pas de wildcard)
resource "aws_iam_role_policy" "ecs_task_custom" {
  name = "${var.name_prefix}-ecs-task-custom"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadDBSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [var.db_secret_arn]
      },
      {
        Sid    = "AllowSSMMessages"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── Génération automatique du certificat SSL/TLS pour l'ALB ──────────────────

# 1. Génère une clé privée RSA sécurisée
resource "tls_private_key" "petclinic_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. Génère le certificat auto-signé associé à cette clé
resource "tls_self_signed_cert" "petclinic_self_signed" {
  private_key_pem = tls_private_key.petclinic_key.private_key_pem

  subject {
    common_name  = "petclinic-isi-prod"
    organization = "ISI Dakar"
  }

  validity_period_hours = 8760 # Valide pendant 1 an (365 jours)

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# 3. Téléverse automatiquement ce certificat dans IAM
resource "aws_iam_server_certificate" "petclinic_automated_cert" {
  name             = "${var.name_prefix}-automated-cert"
  certificate_body = tls_self_signed_cert.petclinic_self_signed.cert_pem
  private_key      = tls_private_key.petclinic_key.private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}

# ── Rôle de déploiement OIDC pour GitHub Actions (100% dynamique) ──
# ── Récupération ou création du fournisseur OIDC GitHub ──
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# ── Création AUTOMATIQUE du rôle de CI "petclinic-ci" ──
resource "aws_iam_role" "github_actions_ci" {
  name = "petclinic-ci"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Utilise la variable dynamique github_repo configurée plus tôt
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "petclinic-ci"
  }
}

# Attachement des privilèges Administrateur au rôle automatique de CI
resource "aws_iam_role_policy_attachment" "github_ci_admin" {
  role       = aws_iam_role.github_actions_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
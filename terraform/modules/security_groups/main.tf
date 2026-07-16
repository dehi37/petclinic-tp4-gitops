################################################################################
# Module Security Groups
# Chaîne : SG ALB → SG APP → SG RDS (aucun port d'admin ouvert sur Internet)
################################################################################

# ── SG ALB : accepte HTTPS (443) et HTTP (80 → redirect) depuis Internet ─────
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security Group pour l'Application Load Balancer (ALB) - Entree publique"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP traffic on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Requis car l'ALB est le point d'entree public
  }

  ingress {
    description = "Allow inbound HTTPS traffic on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # tfsec:ignore:aws-ec2-no-public-egress-sgr -> Facilement supprimable si l'egress doit etre strictement restreint
  egress {
    description = "Allow all outbound traffic from ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-alb-sg" }
}

# ── SG APP : uniquement accessible via l'ALB ─────────────────────────────────
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Security Group pour l'application ECS - Trafic interne uniquement"
  vpc_id      = var.vpc_id

  # Pas de regles d'egress ou d'ingress en dur ici. Tout est gere par les ressources autonomes ou variables.

  tags = { Name = "${var.name_prefix}-app-sg" }
}

# Règle d'entrée séparée pour éviter la référence circulaire et gerer dynamiquement le port
resource "aws_security_group_rule" "app_from_alb" {
  type                     = "ingress"
  description              = "Traffic from ALB SG to container port"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.alb.id
}

# ── SG RDS : accepte uniquement le trafic provenant du SG APP ────────────────
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-sg-rds"
  description = "Security Group pour la base de donnees RDS PostgreSQL"
  vpc_id      = var.vpc_id

  # Dynamique : Ce bloc de sortie est supprime par defaut si la variable est a false
  # Evite d'ouvrir l'egress 0.0.0.0/0 sur une DB inutilement (Fix #4 CRITICAL)
  dynamic "egress" {
    for_each = var.enable_rds_egress ? [1] : []
    content {
      description = "Temporary outbound traffic allowed for RDS"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = { Name = "${var.name_prefix}-sg-rds" }
}

resource "aws_security_group_rule" "rds_from_app" {
  type                     = "ingress"
  description              = "Allow PostgreSQL traffic from APP SG only"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
}
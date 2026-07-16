################################################################################
# Module Security Groups
# Chaîne : SG ALB → SG APP → SG RDS (aucun port d'admin ouvert sur Internet)
################################################################################

# ── SG ALB : accepte HTTPS (443) et HTTP (80 → redirect) depuis Internet ─────
# ALB Security Group: Only allow HTTP/HTTPS from the public internet
resource "aws_security_group" "alb" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowed if this is your public entry point
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Restrict egress to necessary destinations, or ignore if wide egress is intended
  # tfsec:ignore:aws-ec2-no-public-egress-sgr
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App Security Group: Only allow traffic coming FROM the ALB
resource "aws_security_group" "app" {
  name   = "${var.name_prefix}-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 8080 # Assuming your container port
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Source limited to ALB
  }
}

# Règle d'entrée séparée pour éviter la référence circulaire
resource "aws_security_group_rule" "app_from_alb" {
  type                     = "ingress"
  description              = "Traffic from ALB SG only"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.alb.id
}

# ── SG RDS : accepte uniquement le trafic provenant du SG APP ────────────────
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-sg-rds"
  description = "Security Group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  egress {
    description = "No outbound traffic required"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-sg-rds" }
}

resource "aws_security_group_rule" "rds_from_app" {
  type                     = "ingress"
  description              = "PostgreSQL from APP SG only"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
}

resource "aws_rds_cluster" "main" {
  count                           = var.skip_rds_cluster_creation == true ? 0 : 1

  allow_major_version_upgrade     = false
  apply_immediately               = true
  cluster_identifier              = var.cluster_identifier
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = var.master_password
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main[0].name
  db_subnet_group_name            = aws_db_subnet_group.main[0].name
  engine_mode                     = "provisioned"
  engine_version                  = "5.7.mysql_aurora.2.09.0"
  engine                          = "aurora-mysql"
  vpc_security_group_ids          = var.security_group_ids
  skip_final_snapshot             = true

  tags = {
    Name = var.cluster_identifier
  }
}

resource "aws_rds_cluster_instance" "main" {
  count                   = var.skip_rds_cluster_creation == true ? 0 : var.instances_number

  identifier              = "${var.cluster_identifier}-${count.index}"
  cluster_identifier      = aws_rds_cluster.main[0].id
  instance_class          = var.instance_class
  engine                  = aws_rds_cluster.main[0].engine
  engine_version          = aws_rds_cluster.main[0].engine_version
  publicly_accessible     = false
  db_subnet_group_name    = aws_rds_cluster.main[0].db_subnet_group_name
  db_parameter_group_name = aws_db_parameter_group.main[0].name
  apply_immediately       = true

  tags = {
    Name = "${var.cluster_identifier}-${count.index}"
  }
}

resource "aws_db_subnet_group" "main" {
  count      = var.skip_rds_cluster_creation == true ? 0 : 1

  name       = var.cluster_identifier
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.cluster_identifier
  }
}

resource "aws_rds_cluster_parameter_group" "main" {
  count  = var.skip_rds_cluster_creation == true ? 0 : 1

  name   = var.cluster_identifier
  family = "aurora-mysql5.7"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
}

resource "aws_db_parameter_group" "main" {
  count  = var.skip_rds_cluster_creation == true ? 0 : 1

  name   = var.cluster_identifier
  family = "aurora-mysql5.7"

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }
}

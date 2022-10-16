provider "aws" {
  region = "us-east-1"
}

resource "random_string" "auth" {
  count   = 1
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "db_pass" {
  count = 1
  name  = "db-pass"
  type  = "SecureString"
  value = random_string.auth[0].result
}

resource "aws_security_group" "rds_sg_portfoliov3" {
  name        = "rds_sg_portfoliov3"
  description = "Allow Connection to DB"


  ingress {
    description      = "allow rds connections"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow RDS DB"
  }
}


resource "aws_db_instance" "portfoliov3_db_main" {
  count             = 1
  allocated_storage = 10
  identifier        = "portfoliov3-db-main"
  instance_class    = "db.t2.micro"
  username          = "root"
  password          = aws_ssm_parameter.db_pass[count.index].value
  # security_group_names   = [aws_security_group.rds_sg_portfoliov3.name]
  vpc_security_group_ids = [aws_security_group.rds_sg_portfoliov3.id]
  engine                 = "mysql"
  engine_version         = "5.7"
  port                   = 3306
  apply_immediately      = true
  deletion_protection    = true
  skip_final_snapshot    = true
  publicly_accessible    = true

  tags = {
    Name = "portfoliov3 DB"
  }
}





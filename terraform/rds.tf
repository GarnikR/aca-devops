
resource "aws_db_instance" "rds_mysql" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "12345678"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}


resource "aws_security_group" "rds_sg" {
  name = "rds_sg"
  description = "RDS (terraform-managed)"
  vpc_id      = "vpc-000f813df761f1785"

  # Only MySQL in from any ip address
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_ssh.id]
  }

 egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 }

output "RDS_IP" {
value = aws_db_instance.rds_mysql.address
 }


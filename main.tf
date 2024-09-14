resource "aws_instance" "june" {
  cidr_block = "196.198.0.0/16"
vpc_id = aws_instance.vpc_id
}
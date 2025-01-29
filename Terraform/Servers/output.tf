# Step 10 - Add output variables
output "public_ip" {
  value = aws_instance.my_amazon.public_ip
}

output "aws_mysql_ecr_repo_url" {
  value = aws_ecr_repository.mysql_ecr_repo.repository_url
}
 
output "aws_mysql_ecr_repo_arn" {
  value = aws_ecr_repository.mysql_ecr_repo.arn
}

output "aws_app_ecr_repo_url" {
  value = aws_ecr_repository.app_ecr_repo.repository_url
}
 
output "aws_app_ecr_repo_arn" {
  value = aws_ecr_repository.app_ecr_repo.arn
}

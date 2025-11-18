locals {
  repo_outputs = {
    for name, repo in aws_ecr_repository.this :
    name => {
      name = repo.name
      arn  = repo.arn
      uri  = repo.repository_url
    }
  }
}

output "repository_names" {
  description = "Map of repository short names to their full ECR names."
  value       = { for name, meta in local.repo_outputs : name => meta.name }
}

output "repository_arns" {
  description = "Map of repository short names to their ARNs."
  value       = { for name, meta in local.repo_outputs : name => meta.arn }
}

output "repository_urls" {
  description = "Map of repository short names to their URLs."
  value       = { for name, meta in local.repo_outputs : name => meta.uri }
}

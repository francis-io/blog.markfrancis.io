locals {
  dns_zone_id_markfrancis_io = "Z24AEWA6EIR2O1"
  dns_hosted_zone_name = "markfrancis.io"
}

resource "github_repository" "blog" {
  name        = "francis-io.github.io"
  description = "Codebase for https://markfrancis.io"
  homepage_url = "https://markfrancis.io"

  visibility = "public"

  has_issues = false
  has_discussions = false
  has_projects = false
  has_wiki = false
  has_downloads = false
  is_template = false

  delete_branch_on_merge = true

  archive_on_destroy = true

  pages {
    source {
      branch = "main"
    }
    build_type = "workflow"
    cname = local.dns_hosted_zone_name
  }
}

resource "aws_route53_record" "apex" {
  zone_id = local.dns_zone_id_markfrancis_io
  name = local.dns_hosted_zone_name
  type = "A"
  ttl = "3600"
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
}

resource "aws_route53_record" "www" {
  zone_id = local.dns_zone_id_markfrancis_io
  name = "www.${local.dns_hosted_zone_name}"
  type = "CNAME"
  ttl = "3600"
  records = ["francis-io.github.io"]
}

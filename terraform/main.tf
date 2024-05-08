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
  ttl = local.dns_ttl
  records = local.github_pages_ips
}

resource "aws_route53_record" "www" {
  zone_id = local.dns_zone_id_markfrancis_io
  name = "www.${local.dns_hosted_zone_name}"
  type = "CNAME"
  ttl = local.dns_ttl
  records = [basename(github_repository.blog.html_url)]
}

locals {
  dns_zone_id_markfrancis_io = "Z24AEWA6EIR2O1"
  dns_hosted_zone_name = "markfrancis.io"
  dns_ttl = "3600"
  github_ips_url = "https://api.github.com/meta"
  # curl -s https://api.github.com/meta | jq -r '.pages[]'
  # IPs 192.30.0.0/16 are an old set that don't support https. I also want to exclude IPv6.
  github_pages_ips_and_cidr = [
    for ip in jsondecode(data.http.github_meta.response_body).pages :
    ip if !startswith(ip, "192.30.") && !endswith(ip, "/128")
  ]
  # strip off the cidr notation at the end
  github_pages_ips = tolist([for ip in local.github_pages_ips_and_cidr : split("/", ip)[0] ])
}

data "http" "github_meta" {
  url = local.github_ips_url
}

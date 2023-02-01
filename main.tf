terraform {
  cloud {
    organization = "Attituding"

    workspaces {
      name = "cloudflare_zero_trust_ad_block"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    curl = {
      version = "1.0.2"
      source  = "anschoewe/curl"
    }
  }
}

variable "cf_api_token" {
  type      = string
  sensitive = true
}

variable "cf_account_id" {
  type = string
}

variable "hosts_invalid" {
  type    = list(string)
  default = ["127.0.0.1  localhost", "::1  localhost"]
}

// uses the hosts file format
variable "hosts_urls" {
  type    = list(string)
  default = [
    "https://adaway.org/hosts.txt",
    "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext",
    "https://blocklistproject.github.io/Lists/ransomware.txt",
    "https://blocklistproject.github.io/Lists/tracking.txt"
  ]
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

data "curl" "get_hosts" {
  for_each    = toset(var.hosts_urls)
  http_method = "GET"
  uri         = each.value
}

locals {
  hosts           = flatten([for k, v in data.curl.get_hosts : split("\n", v.response)])
  hosts_formatted = distinct([for host in local.hosts : split(" ", host)[1] if host != "" && !startswith(host, "#") && !contains(var.hosts_invalid, host)])
  hosts_lists     = chunklist(local.hosts_formatted, 1000)

  cf_hosts_lists           = [for key, value in cloudflare_teams_list.hosts_lists : value.id]
  cf_hosts_lists_formatted = [for v in local.cf_hosts_lists : format("$%s", replace(v, "-", ""))]
  cf_hosts_traffic         = join(" or ", formatlist("any(dns.domains[*] in %s)", local.cf_hosts_lists_formatted))
}

resource "cloudflare_teams_list" "hosts_lists" {
  account_id = var.cf_account_id

  count = min(length(local.hosts_lists), 100)

  name  = "hosts_list_${count.index}"
  type  = "DOMAIN"
  items = element(local.hosts_lists, count.index)
}

resource "cloudflare_teams_rule" "advertisments" {
  account_id = var.cf_account_id

  name        = "Advertisments"
  description = ""

  enabled    = true
  precedence = 5

  filters = ["dns"]
  traffic = "any(dns.content_category[*] in {66 85}) or ${local.cf_hosts_traffic}"
  action  = "block"
}
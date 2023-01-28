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
  type = string
  sensitive = true
}

variable "cf_account_id" {
  type = string
}

variable "hosts_invalid" {
  type = list(string)
  default = ["127.0.0.1  localhost", "::1  localhost"]
}

variable "hosts_url" {
  type = string
  default = "https://adaway.org/hosts.txt"
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

data "curl" "get_hosts" {
  http_method = "GET"
  uri         = var.hosts_url
}

locals {
  hosts           = split("\n", data.curl.get_hosts.response)
  hosts_formatted = [for host in local.hosts : split(" ", host)[1] if host != "" && !startswith(host, "#") && !contains(var.hosts_invalid, host)]
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
  precedence = 3

  filters = ["dns"]
  traffic = "any(dns.content_category[*] in {66 85}) or ${local.cf_hosts_traffic}"
  action  = "block"
}
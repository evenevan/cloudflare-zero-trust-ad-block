# Cloudflare Zero Trust Ad Block

This Terraform setup allows for ad blocking via Cloudflare Gateway's DNS blocking.

## About

This project automatically fetches, parses, uploads, and sets host lists to Cloudflare with GitHub Actions and Terraform (Cloud).

## Setup

### TODO

## Prerequisites

### TODO

## Attribution

Some aspects of this project are inspired by [marco-lancini/utils/terraform/cloudflare-gateway-adblocking]("https://github.com/marco-lancini/utils/tree/main/terraform/cloudflare-gateway-adblocking").

Host lists used by default:
https://adaway.org/hosts.txt
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
https://blocklistproject.github.io/Lists/ransomware.txt
https://blocklistproject.github.io/Lists/tracking.txt
# Cloudflare Zero Trust Ad Block

This Terraform setup allows for ad blocking via Cloudflare Gateway's DNS blocking.

## Introduction

This project automatically fetches, parses, uploads, and sets host lists to Cloudflare with GitHub Actions and Terraform (Cloud). For now, this repository only exists to demonstrate how one could use Cloudflare Zero Trust, GitHub, and Terraform to block ads and maintain such automatically.

Feel free to fork and use, but minimal support will be offered if you run into issues.

## Attribution

Some aspects of this project are inspired by the work of [Marco Lancini](https://github.com/marco-lancini) through his [similar project](https://github.com/marco-lancini/utils/tree/main/terraform/cloudflare-gateway-adblocking). One major difference is that his approach only uses GitHub Actions to update the host file, whereas my approach uses GitHub Actions to run the Terraform configuration.

Default host lists:<br>
https://adaway.org/hosts.txt<br>
https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext<br>
https://blocklistproject.github.io/Lists/ransomware.txt<br>
https://blocklistproject.github.io/Lists/tracking.txt
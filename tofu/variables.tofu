variable "bw_server" {
  type    = string
  default = "https://vault.hpfr.ch"
}

variable "proxmox_url" { type = string }
variable "proxmox_cluster" { type = string }
variable "proxmox_node" { type = string }
variable "proxmox_user" { type = string }

variable "cloudflare_state_access_key" { type = string }
variable "cloudflare_state_secret_key" { type = string }
variable "cloudflare_state_bucket_name" {
  type    = string
  default = "schaermu-terraform-state"
}
variable "cloudflare_state_endpoint_url" {
  type    = string
  default = "https://59469c6e9b7a0c72d7efceab1b0152b5.r2.cloudflarestorage.com"
}

variable "infisical_workspace_id" { type = string }
variable "infisical_client_id" { type = string }
variable "infisical_client_secret" {
  type      = string
  sensitive = true
}

terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket                      = var.cloudflare_state_bucket_name
    key                         = "terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    access_key                  = var.cloudflare_state_access_key
    secret_key                  = var.cloudflare_state_secret_key
    endpoints                   = { s3 = var.cloudflare_state_endpoint_url }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.88,<1.0.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = ">=0.16.0,<1.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4,<5"
    }
    infisical = {
      version = ">=0.16.0,<1.0.0"
      source  = "infisical/infisical"
    }
  }
}

ephemeral "infisical_secret" "bw_email" {
  name         = "BW_EMAIL"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/opentofu"
}

ephemeral "infisical_secret" "bw_master_password" {
  name         = "BW_MASTER_PASSWORD"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/opentofu"
}

ephemeral "infisical_secret" "bw_client_id" {
  name         = "BW_CLIENT_ID"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/opentofu"
}

ephemeral "infisical_secret" "bw_client_secret" {
  name         = "BW_CLIENT_SECRET"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/opentofu"
}

ephemeral "infisical_secret" "pve_api_token" {
  name         = "PVE_API_TOKEN"
  env_slug     = "prod"
  workspace_id = var.infisical_workspace_id
  folder_path  = "/opentofu"
}

locals {
  provider_secrets = {
    bw_email           = ephemeral.infisical_secret.bw_email.value
    bw_master_password = ephemeral.infisical_secret.bw_master_password.value
    bw_client_id       = ephemeral.infisical_secret.bw_client_id.value
    bw_client_secret   = ephemeral.infisical_secret.bw_client_secret.value
    pve_api_token      = ephemeral.infisical_secret.pve_api_token.value
  }
}

data "bitwarden_item_ssh_key" "proxmox" {
  search = "terraform@proxmox"
}

provider "bitwarden" {
  email           = local.provider_secrets.bw_email
  master_password = local.provider_secrets.bw_master_password
  client_id       = local.provider_secrets.bw_client_id
  client_secret   = local.provider_secrets.bw_client_secret
  server          = var.bw_server

  experimental {
    embedded_client = true
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_url
  api_token = local.provider_secrets.pve_api_token
  insecure  = true

  ssh {
    agent       = false
    private_key = <<EOF
${data.bitwarden_item_ssh_key.proxmox.private_key}
EOF
    username    = var.proxmox_user
  }
}

provider "cloudflare" {
}

provider "infisical" {
  host = "https://eu.infisical.com"
  auth = {
    universal = {
      client_id     = var.infisical_client_id
      client_secret = var.infisical_client_secret
    }
  }
}

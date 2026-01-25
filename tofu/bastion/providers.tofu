terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.88,<1.0.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = ">=0.16.0,<1.0.0"
    }
  }
}


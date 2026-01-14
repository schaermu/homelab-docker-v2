data "bitwarden_item_ssh_key" "donnerchuebu" {
  search = "schaermu@donnerchuebu"
}

data "bitwarden_item_ssh_key" "klappchuebu" {
  search = "schaermu@klappchuebu"
}

module "docker_swarm" {
  source = "./docker-swarm"
  proxmox = {
    cluster = var.proxmox_cluster
    node    = var.proxmox_node
    api_url = var.proxmox_url
  }

  swarm = {
    name       = "homelab-swarm"
    base_vm_id = 100
    image = {
      checksum      = "f0442f3cd0087a609ecd5241109ddef0cbf4a1e05372e13d82c97fc77b35b2d8ecff85aea67709154d84220059672758508afbb0691c41ba8aa6d76818d89d65"
      checksum_type = "sha512"
      version       = "13"
      url           = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
    }

    management = {
      ssh_public_keys = [data.bitwarden_item_ssh_key.donnerchuebu.public_key, data.bitwarden_item_ssh_key.klappchuebu.public_key]
    }

    specs = {
      manager = {
        count  = 3
        cpu    = 2
        memory = 2048
      }
      worker = {
        count  = 2
        cpu    = 4
        memory = 16384
      }
    }

    network = {
      bridge  = "vmbr0"
      cidr    = "192.168.1.0/24"
      gateway = "192.168.1.1"
      dns     = ["192.168.1.11"]
    }
  }
}

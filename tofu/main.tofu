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
    name                  = "homelab-swarm"
    base_vm_id            = 100
    datastore_id          = "local-vms"
    template_datastore_id = "local-bootstrap"
    image_name            = "debian-13-genericcloud-amd64-shrink.img"

    management = {
      ssh_public_keys = [data.bitwarden_item_ssh_key.donnerchuebu.public_key, data.bitwarden_item_ssh_key.klappchuebu.public_key]
    }

    specs = {
      manager = {
        count         = 1
        first_hostnum = 30
        cpu           = 2
        memory        = 4096
      }
      worker = {
        count         = 1
        first_hostnum = 35
        cpu           = 4
        memory        = 16384
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

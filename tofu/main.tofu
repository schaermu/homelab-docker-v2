variable "template_datastore_id" {
  default = "local-bootstrap"
}

variable "datastore_id" {
  default = "local-vms"
}

data "bitwarden_item_ssh_key" "donnerchuebu" {
  search = "schaermu@donnerchuebu"
}

data "bitwarden_item_ssh_key" "klappchuebu" {
  search = "schaermu@klappchuebu"
}

module "bastion" {
  source = "./bastion"
  proxmox = {
    cluster = var.proxmox_cluster
    node    = var.proxmox_node
    api_url = var.proxmox_url
  }

  bastion = {
    name                  = "bastion"
    vm_id                 = 120
    datastore_id          = var.datastore_id
    template_datastore_id = var.template_datastore_id
    disk_image_id         = data.proxmox_virtual_environment_file.debian_iso.id
    user_data_file_id     = proxmox_virtual_environment_file.user_data_base_cloud_config.id
    tags                  = ["bastion", "ssh-access"]

    specs = {
      cpu       = 1
      memory    = 1024
      disk_size = 32
    }

    network = {
      bridge  = "vmbr0"
      ip      = "192.168.1.50"
      gateway = "192.168.1.1"
      dns     = ["1.1.1.1", "1.0.0.1"]
    }
  }
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
    datastore_id          = var.datastore_id
    template_datastore_id = var.template_datastore_id
    disk_image_id         = data.proxmox_virtual_environment_file.debian_iso.id

    management = {
      ssh_public_keys = [
        data.bitwarden_item_ssh_key.donnerchuebu.public_key,
        data.bitwarden_item_ssh_key.klappchuebu.public_key
      ]
    }

    specs = {
      default_disk_size = 128
      storage_disk_size = 512
      manager = {
        count         = 3
        first_hostnum = 31 # 30 is VIP for keepalived
        cpu           = 2
        memory        = 4096
      }
      worker = {
        count         = 3
        first_hostnum = 40
        cpu           = 2
        memory        = 16384
      }
    }

    network = {
      bridge  = "vmbr0"
      cidr    = "192.168.1.0/24"
      gateway = "192.168.1.1"
      dns     = ["1.1.1.1", "1.0.0.1"]
    }
  }
}

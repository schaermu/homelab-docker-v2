variable "proxmox" {
  description = "Proxmox VE configuration"
  type = object({
    cluster = string,
    node    = string,
    api_url = string,
  })
}

variable "swarm" {
  description = "Docker swarm configuration"
  type = object({
    name       = string,
    base_vm_id = optional(number, 100),

    image = object({
      checksum      = string,
      checksum_type = string,
      version       = string,
      url           = string
    })

    management = object({
      ssh_public_keys = list(string)
    })

    specs = object({
      manager = object({
        count  = number,
        cpu    = number,
        memory = number
      }),
      worker = object({
        count  = number,
        cpu    = number,
        memory = number
      })
    })

    network = object({
      bridge  = string,
      cidr    = string
      gateway = string,
      dns     = optional(set(string))
    })
  })
}

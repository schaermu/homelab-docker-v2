locals {
  machines = {
    for item in concat(
      [for i in range(var.swarm.specs.manager.count) : { role = "manager", index = i }],
      [for i in range(var.swarm.specs.worker.count) : { role = "worker", index = i }]
      ) : format("%s-%02d", item.role, item.index + 1) => {
      role     = item.role
      vm_id    = var.swarm.base_vm_id + (item.role == "manager" ? item.index : var.swarm.specs.manager.count + item.index)
      hostname = format("%s-%02d", item.role, item.index + 1)
      tags     = ["docker", item.role]
      ip       = cidrhost(var.swarm.network.cidr, (item.role == "manager" ? var.swarm.specs.manager.first_hostnum : var.swarm.specs.worker.first_hostnum) + item.index)
      cpu      = item.role == "manager" ? var.swarm.specs.manager.cpu : var.swarm.specs.worker.cpu
      memory   = item.role == "manager" ? var.swarm.specs.manager.memory : var.swarm.specs.worker.memory
    }
  }
}

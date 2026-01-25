# generated ansible inventory
# created: ${timestamp()}

[bastion]
${bastion.name} ansible_host=${bastion.ip}

[managers]
%{ for m in managers ~}
${m.name} ansible_host=${m.ip}
%{ endfor ~}

[workers]
%{ for w in workers ~}
${w.name} ansible_host=${w.ip}
%{ endfor ~}

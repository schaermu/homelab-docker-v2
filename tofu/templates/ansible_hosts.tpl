# generated ansible inventory
# created: ${timestamp()}

[bastion]
${bastion.name} ansible_host=${bastion.ip}

[dns]
${dns.name} ansible_host=${dns.ip}

[managers]
%{ for m in managers ~}
${m.name} ansible_host=${m.ip}
%{ endfor ~}

[workers]
%{ for w in workers ~}
${w.name} ansible_host=${w.ip}
%{ endfor ~}

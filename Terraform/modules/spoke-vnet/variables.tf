variable resource_group_id {}
variable location {}
variable tags {
  type                         = map
}

variable address_space {}
variable bastion_subnet_range {}
variable deploy_managed_bastion {
  type                         = bool
}
variable dns_servers {
  default                      = []
}
variable gateway_ip_address {}
variable hub_gateway_dependency {}
variable hub_virtual_network_id {}
variable enable_routetable_for_subnets {
  type                         = list
}
variable private_dns_zones {
  type                         = list
}
variable spoke_virtual_network_name {}
variable service_endpoints {
  type                         = map
}
variable subnets {
  type                         = map
}
variable subnet_delegations {
  type                         = map
}
variable use_hub_gateway {
  type                         = bool
}

variable diagnostics_storage_id {}
variable diagnostics_workspace_resource_id {}
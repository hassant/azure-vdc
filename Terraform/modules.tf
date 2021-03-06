module auto_shutdown {
  source                       = "./modules/auto-shutdown"
  resource_environment         = local.environment
  resource_group_id            = azurerm_resource_group.vdc_rg.id
  location                     = azurerm_resource_group.vdc_rg.location
  app_resource_group           = local.iaas_app_resource_group
  app_storage_replication_type = var.app_storage_replication_type
  tags                         = local.tags
  resource_group_ids           = [
                                 azurerm_resource_group.vdc_rg.id,
                                 module.iis_app.app_resource_group_id
  ]

  deploy_auto_shutdown         = var.deploy_auto_shutdown

  diagnostics_instrumentation_key = azurerm_application_insights.vdc_insights.instrumentation_key
  diagnostics_storage_id       = azurerm_storage_account.vdc_diag_storage.id
  diagnostics_workspace_resource_id = azurerm_log_analytics_workspace.vcd_workspace.id
}

module iaas_spoke_vnet {
  source                       = "./modules/spoke-vnet"
  resource_group_id            = azurerm_resource_group.vdc_rg.id
  location                     = azurerm_resource_group.vdc_rg.location
  tags                         = local.tags

  address_space                = var.vdc_config["iaas_spoke_range"]
  bastion_subnet_range         = var.vdc_config["iaas_spoke_bastion_subnet"]
  deploy_managed_bastion       = var.deploy_managed_bastion
  dns_servers                  = azurerm_virtual_network.hub_vnet.dns_servers
  enable_routetable_for_subnets = ["app","data"]
  gateway_ip_address           = azurerm_firewall.iag.ip_configuration.0.private_ip_address # Delays provisioning to start after Azure FW is provisioned
# gateway_ip_address           = cidrhost(var.vdc_config["iag_subnet"], 4) # Azure FW uses the 4th available IP address in the range
  hub_gateway_dependency       = module.p2s_vpn.gateway_id
  hub_virtual_network_id       = azurerm_virtual_network.hub_vnet.id
  private_dns_zones            = [for z in azurerm_private_dns_zone.zone : z.name]
  service_endpoints            = {
    app                        = []
    data                       = []
  }
  spoke_virtual_network_name   = "${azurerm_resource_group.vdc_rg.name}-iaas-spoke-network"
  subnets                      = {
    app                        = var.vdc_config["iaas_spoke_app_subnet"]
    data                       = var.vdc_config["iaas_spoke_data_subnet"]
  }
  subnet_delegations           = {}
  use_hub_gateway              = var.deploy_vpn

  diagnostics_storage_id       = azurerm_storage_account.vdc_diag_storage.id
  diagnostics_workspace_resource_id = azurerm_log_analytics_workspace.vcd_workspace.id
}

locals {
  release_agent_dependencies   = concat(module.iaas_spoke_vnet.access_dependencies,
                                 [
                                 azurerm_firewall_application_rule_collection.iag_app_rules.id,
                                 azurerm_firewall_network_rule_collection.iag_net_outbound_rules.id
#                                module.p2s_vpn.gateway_id
  ])
  # HACK: This value is dependent on all elements of the list being created
  release_agent_dependency     = join("|",[for dep in local.release_agent_dependencies : substr(dep,0,1)])
}

module iis_app {
  source                       = "./modules/iis-app"
  resource_environment         = local.environment
  resource_group               = local.iaas_app_resource_group
  vdc_resource_group_id        = azurerm_resource_group.vdc_rg.id
  location                     = azurerm_resource_group.vdc_rg.location
  tags                         = local.tags

  admin_username               = var.admin_username
  admin_password               = local.password
  app_devops                   = var.app_devops
  app_url                      = local.iaas_app_url
  app_web_vms                  = var.app_web_vms
  app_web_vm_number            = var.app_web_vm_number
  app_db_lb_address            = var.vdc_config["iaas_spoke_app_db_lb_address"]
  app_db_vms                   = var.app_db_vms
  app_db_vm_number             = var.app_db_vm_number
  app_subnet_id                = lookup(module.iaas_spoke_vnet.subnet_ids,"app","")
  data_subnet_id               = lookup(module.iaas_spoke_vnet.subnet_ids,"data","")
  deploy_connection_monitors   = var.deploy_connection_monitors
  release_agent_dependency     = local.release_agent_dependency
  diagnostics_storage_id       = azurerm_storage_account.vdc_diag_storage.id
  diagnostics_watcher_id       = var.deploy_connection_monitors ? azurerm_network_watcher.vdc_watcher[0].id : null
  diagnostics_workspace_resource_id = azurerm_log_analytics_workspace.vcd_workspace.id
  diagnostics_workspace_workspace_id = azurerm_log_analytics_workspace.vcd_workspace.workspace_id
  diagnostics_workspace_key    = azurerm_log_analytics_workspace.vcd_workspace.primary_shared_key
}

module managed_bastion_hub {
  source                       = "./modules/managed-bastion"
  resource_group_id            = azurerm_resource_group.vdc_rg.id
  location                     = azurerm_resource_group.vdc_rg.location
  tags                         = local.tags

  subnet_range                 = var.vdc_config["hub_bastion_subnet"]
  virtual_network_id           = azurerm_virtual_network.hub_vnet.id

  diagnostics_storage_id       = azurerm_storage_account.vdc_diag_storage.id
  diagnostics_workspace_resource_id = azurerm_log_analytics_workspace.vcd_workspace.id

  deploy_managed_bastion       = var.deploy_managed_bastion
}

module p2s_vpn {
  source                       = "./modules/p2s-vpn"
  resource_group_id            = azurerm_resource_group.vdc_rg.id
  location                     = azurerm_resource_group.vdc_rg.location
  tags                         = local.tags

  virtual_network_id           = azurerm_virtual_network.hub_vnet.id
  subnet_range                 = var.vdc_config["hub_vpn_subnet"]
  vpn_range                    = var.vdc_config["vpn_range"]
  vpn_root_cert_name           = var.vpn_root_cert_name
  vpn_root_cert_file           = var.vpn_root_cert_file

  diagnostics_storage_id       = azurerm_storage_account.vdc_diag_storage.id
  diagnostics_workspace_resource_id = azurerm_log_analytics_workspace.vcd_workspace.id

  deploy_vpn                   = var.deploy_vpn
}

module paas_app {
  source                       = "./modules/paas-app"
  resource_group_name          = local.paas_app_resource_group
  vdc_resource_group_id        = azurerm_resource_group.vdc_rg.id
  location                     = azurerm_resource_group.vdc_rg.location
  tags                         = local.tags

  admin_ips                    = local.admin_ips
  admin_ip_ranges              = local.admin_cidr_ranges
  admin_username               = var.admin_username
  management_subnet_ids        = [module.paas_spoke_vnet.bastion_subnet_id,azurerm_subnet.mgmt_subnet.id]
  database_import              = var.paas_app_database_import
  database_template_storage_key= var.app_database_template_storage_key
  dba_login                    = "Terraform"
  dba_object_id                = data.azurerm_client_config.current.service_principal_object_id
# dba_login                    = var.dba_login
# dba_object_id                = var.dba_object_id
  iag_subnet_id                = azurerm_subnet.iag_subnet.id
  integrated_subnet_id         = lookup(module.paas_spoke_vnet.subnet_ids,"appservice","")
  integrated_subnet_range      = var.vdc_config["paas_spoke_appsvc_subnet"]
  integrated_vnet_id           = module.paas_spoke_vnet.spoke_virtual_network_id
  storage_replication_type     = var.app_storage_replication_type
  waf_subnet_id                = azurerm_subnet.waf_subnet.id

  diagnostics_instrumentation_key = azurerm_application_insights.vdc_insights.instrumentation_key
  diagnostics_storage_id       = azurerm_storage_account.vdc_diag_storage.id
  diagnostics_workspace_resource_id = azurerm_log_analytics_workspace.vcd_workspace.id
}

module paas_spoke_vnet {
  source                       = "./modules/spoke-vnet"
  resource_group_id            = azurerm_resource_group.vdc_rg.id
  location                     = azurerm_resource_group.vdc_rg.location
  tags                         = local.tags

  address_space                = var.vdc_config["paas_spoke_range"]
  bastion_subnet_range         = var.vdc_config["paas_spoke_bastion_subnet"]
  deploy_managed_bastion       = var.deploy_managed_bastion
  dns_servers                  = azurerm_virtual_network.hub_vnet.dns_servers
  enable_routetable_for_subnets = []
  gateway_ip_address           = azurerm_firewall.iag.ip_configuration.0.private_ip_address # Delays provisioning to start after Azure FW is provisioned
  hub_gateway_dependency       = module.p2s_vpn.gateway_id
  hub_virtual_network_id       = azurerm_virtual_network.hub_vnet.id
  private_dns_zones            = [for z in azurerm_private_dns_zone.zone : z.name]
  service_endpoints            = {
    appservice                 = ["Microsoft.EventHub","Microsoft.Storage"]
  }
  spoke_virtual_network_name   = "${azurerm_resource_group.vdc_rg.name}-paas-spoke-network"
  subnets                      = {
    appservice                 = var.vdc_config["paas_spoke_appsvc_subnet"]
    data                       = var.vdc_config["paas_spoke_data_subnet"]
  }

  subnet_delegations           = {
    appservice                 = "Microsoft.Web/serverFarms"
  }
  use_hub_gateway              = var.deploy_vpn

  diagnostics_storage_id       = azurerm_storage_account.vdc_diag_storage.id
  diagnostics_workspace_resource_id = azurerm_log_analytics_workspace.vcd_workspace.id
}
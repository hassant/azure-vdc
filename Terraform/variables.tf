variable resource_prefix {
  description                  = "The prefix to put in front of resource names created"
  default                      = "vdc"
}

variable resource_suffix {
  description                  = "The suffix to put at the of resource names created"
  default                      = "" # Empty string triggers a random suffix
}

variable resource_environment {
  description = "The logical environment (tier) resource will be deployed in"
  default     = "" # Empty string defaults to workspace name
}

variable tags {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map

  default = {
    application                = "Automated VDC"
    provisioner                = "terraform"
  }
} 

variable release_web_url {
  description = "The url of the Release Pipeline that deployed this resource"
  default     = "" 
}
variable release_id {
  description = "The ID Release Pipeline that deployed this resource"
  default     = ""
}
variable release_user_email {
  description = "The email address of the user that triggered the pipeline that deployed this resource"
  default     = ""
}

######### Resource Group #########
variable location {
  description                  = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default                      = "westeurope"
}

variable automation_location {
  description                  = "The location/region where the monitoring workspaces will be created."
  default                      = "" # Empty string defaults to workspace_location
}

variable workspace_location {
  description                  = "The location/region where the monitoring workspaces will be created."
  default                      = "" # Empty string defaults to location
}

variable vdc_config {
  type                         = map

  default = {
    vdc_range                  = "10.0.0.0/14"
    hub_range                  = "10.0.0.0/16"
    hub_bastion_subnet         = "10.0.255.192/27"
    hub_iag_subnet             = "10.0.0.0/26"
    hub_waf_subnet             = "10.0.1.64/26"
    hub_mgmt_subnet            = "10.0.2.128/26"
    hub_vpn_subnet             = "10.0.3.224/27"
    iaas_spoke_range           = "10.1.0.0/16"
    iaas_spoke_bastion_subnet  = "10.1.255.192/27"
    iaas_spoke_app_subnet      = "10.1.1.0/24"
    iaas_spoke_data_subnet     = "10.1.2.0/24"
    iaas_spoke_app_web_lb_address = "10.1.1.4"
    iaas_spoke_app_db_lb_address = "10.1.2.4"
    paas_spoke_range           = "10.2.0.0/16"
    paas_spoke_bastion_subnet  = "10.2.255.192/27"
    paas_spoke_appsvc_subnet   = "10.2.1.0/24"
    paas_spoke_data_subnet     = "10.2.2.0/24"

    vpn_range                  = "192.168.0.0/24"

    hub_bastion_address        = "10.0.2.132"
  }
}

variable app_web_vms {
  default                      = ["10.1.1.5", "10.1.1.6", "10.1.1.7", "10.1.1.8", "10.1.1.9"]
}

variable app_db_vms {
  default                      = ["10.1.2.142", "10.1.2.143", "10.1.2.144", "10.1.2.145", "10.1.2.146"]
}

variable vdc_oms_solutions {
# List of solutions: https://docs.microsoft.com/en-us/rest/api/loganalytics/workspaces/listintelligencepacks
# Get-AzOperationalInsightsIntelligencePack
  default                      = [
  # "ADAssessment",
  # "ADReplication",
    "AgentHealthAssessment",
    "AlertManagement",
    "AntiMalware",
  # "ApplicationInsights", # Depricated
  # "ASRAnalytics",
    "AzureActivity",
    "AzureAppGatewayAnalytics",
    "AzureAutomation",
  # "AzureCdnCoreAnalytics",
  # "AzureDataFactoryAnalytics",
  # "AzureNetworking", # Depricated
    "AzureNSGAnalytics", # Depricated
  # "AzureSecurityOfThings",
    "AzureSQLAnalytics",
  # "AzureWebAppsAnalytics", # Depricated
  # "Backup", # Depricated
    "CapacityPerformance",
  # "ChangeTracking",
  # "CompatibilityAssessment",
  # "ContainerInsights",
  # "Containers",
  # "DeviceHealthProd",
  # "DHCPActivity",
  # "DnsAnalytics",
  # "HDInsight",
  # "HDInsightHadoop",
  # "HDInsightInteractiveQuery",
  # "HDInsightKafka",
  # "HDInsightSpark",
  # "HDInsightStorm",
    "InfrastructureInsights",
    "InternalWindowsEvent",
  # "KeyVault",
  # "KeyVaultAnalytics",
  # "LogicAppB2B",
  # "LogicAppsManagement",
    "LogManagement",
  # "Microsoft365Analytics",
    "NetworkMonitoring",
  # "Office365",
    "ProcessInvestigator",
  # "SCOMAssessment",
    "Security",
    "SecurityCenterFree",
    "SecurityCenterNetworkTraffic",
    "SecurityInsights",
    "ServiceDesk",
  # "ServiceFabric",
    "ServiceMap",
  # "SiteRecovery",
    "SQLAdvancedThreatProtection",
    "SQLAssessment",
  # "SQLThreatDetection",
    "SQLVulnerabilityAssessment",
  # "SurfaceHub",
    "Updates",
    "VMInsights",
  # "VMware",
  # "WaaSUpdateInsights",
  # "WEF_10x",
  # "WEF_10xDSRE",
  # "WEFInternal",
  # "WEFInternalUat",
  # "WindowsDefenderATP",
  # "WindowsDefenderATPStable",
    "WindowsEventForwarding",
  # "WindowsFirewall",
    "WinLog",
  # "WireData",
  # "WireData2"
  ]
}

variable admin_ip_ranges {
  default                      = []
}
variable admin_ips {
  default                      = []
}
variable dba_login {}
variable dba_object_id {}

variable rdp_port {
# default                      = "3389" # Default for protocol
  default                      = "28934"
}

########## Credentials #########
variable admin_username {
  description                  = "The VDC admin user name"
  default                      = "vdcadmin"
}

variable app_devops {
  type                         = map

  default = {
    account                    = "myaccount"
    team_project               = "VDC"
    web_deployment_group       = "AppServers"
    db_deployment_group        = "DBServers"
    pat                        = ""
  }
}

variable app_storage_account_tier {
  description                  = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default                      = "Standard"
}

variable app_storage_replication_type {
  description                  = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS, ZRS etc."
  default                      = "ZRS" # Zone redundant: ZRS
}

variable app_web_vm_number {
  description                  = "Number of web tier VM's to create"
  default                      = "2"
}
variable app_web_vm_size {
  description                  = "Specifies the size of the Web virtual machines."
  default                      = "Standard_D2s_v3"
}
variable app_web_image_publisher {
  description                  = "name of the publisher of the Web image (az vm image list)"
  default                      = "MicrosoftWindowsServer"
}
variable app_web_image_offer {
  description                  = "the name of the offer (az vm image list)"
  default                      = "WindowsServer"
}
variable app_web_image_sku {
  description                  = "image sku to apply (az vm image list)"
  default                      = "2019-Datacenter"
}
variable app_web_image_version {
  description                  = "version of the Web image to apply (az vm image list)"
  default                      = "latest"
}

variable app_db_vm_number {
  description                  = "Number of DB tier VM's to create"
  default                      = "2"
}
variable app_db_vm_size {
  description                  = "Specifies the size of the DB virtual machines."
  default                      = "Standard_D2s_v3"
}
variable app_db_image_publisher {
  description                  = "name of the publisher of the DB image (az vm image list)"
  default                      = "MicrosoftWindowsServer"
}
variable app_db_image_offer {
  description                  = "the name of the offer (az vm image list)"
  default                      = "WindowsServer"
}
variable app_db_image_sku {
  description                  = "image sku to apply (az vm image list)"
  default                      = "2019-Datacenter"
}
variable app_db_image_version {
  description                  = "version of the DB image to apply (az vm image list)"
  default                      = "latest"
}
variable app_database_template_storage_key {}
variable paas_app_database_import {
  type                         = bool
  default                      = false
}
variable vanity_domainname {
  description                  = "The domain part of the vanity url"
}
variable vanity_certificate_name {
  description                  = "The name of the SSL certificate used for vanity url"
}

variable vanity_certificate_path {
  description                  = "The relative path to the SSL certificate PFX file used for vanity url"
}

variable vanity_certificate_password {
  description                  = "The full path to the SSL certificate PFX file used for vanity url"
}

variable vpn_root_cert_name {
  default                      = "P2SRootCert" 
}

variable vpn_root_cert_file {
  description                  = "The relative path to the certificate CER file used for P2S root"
}

variable deploy_auto_shutdown {
  description                  = "Whether to deploy the Auto shutdown function"
  default                      = true
  type                         = bool
}

variable deploy_connection_monitors {
  description                  = "Whether to deploy connection monitors"
  default                      = false
  type                         = bool
}

variable deploy_managed_bastion {
  description                  = "Whether to deploy the Managed Bastion (preview)"
  default                      = true
  type                         = bool
}

variable deploy_vpn {
  description                  = "Whether to deploy the point to Site VPN"
  default                      = false
  type                         = bool
}

variable use_vanity_domain_and_ssl {
  description                  = "Whether to use SSL (HTTPS) for demo application"
  default                      = false
  type                         = bool
}
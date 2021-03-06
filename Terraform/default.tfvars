# tf_deploy.ps1 loads <terraform-worksopace>.tfvars

resource_prefix                = "vdc"
resource_environment           = "dev"
location                       = "eastus"
workspace_location             = "westeurope"

deploy_auto_shutdown           = true
deploy_connection_monitors     = false
deploy_managed_bastion         = true
deploy_vpn                     = false
use_vanity_domain_and_ssl      = true

app_db_vm_number               = 2
app_web_vm_number              = 2
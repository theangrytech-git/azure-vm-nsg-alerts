/*******************************************************************************

PROJECT NAME:       AZURE-VM-NSG-ALERTS
CREATED BY:         THEANGRYTECH-GIT
REPO:               https://github.com/theangrytech-git/azure-vm-nsg-alerts
DESCRIPTION:        This project sets up an Azure environment which includes a
VNet, subnets, an NSG, Azure Firewall, Azure DDoS, a VM plus Disk, Storage
Accounts, Public IP's and Alert Rules.

*******************************************************************************/

/*******************************************************************************
                         CREATE RANDOM GENERATOR
*******************************************************************************/
resource "random_password" "resource" {
    length           = 12
    numeric = true
    lower = true
    upper = true
    special = true
}

resource "random_string" "numbers" {
    length           = 4
    numeric = true
    lower = false
    upper = false
    special = false
}


/*******************************************************************************
                         CREATE RESOURCE GROUPS
*******************************************************************************/

resource "azurerm_resource_group" "compute" {
  name     = var.rg_compute
  location = var.location
}

resource "azurerm_resource_group" "networking" {
  name     = var.rg_networking
  location = var.location
}

resource "azurerm_resource_group" "storage" {
  name     = var.rg_storage
  location = var.location
}

resource "azurerm_resource_group" "monitoring" {
  name     = var.rg_monitoring
  location = var.location
}

resource "azurerm_resource_group" "security" {
  name     = var.rg_security
  location = var.location
}


/*******************************************************************************
                         CREATE VIRTUAL NETWORKS
*******************************************************************************/

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_main
  address_space       = ["10.0.0.0/19"]
  location            = var.location
  resource_group_name = azurerm_resource_group.networking.name
  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos_std.id
    enable = true
  }
  depends_on = [azurerm_network_ddos_protection_plan.ddos_std]
}

resource "azurerm_subnet" "compute" {
  name                 = var.snet_compute
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/28"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "storage" {
  name                 = var.snet_storage
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/28"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "networking" {
  name                 = var.snet_network
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/28"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "security" {
  name                 = var.snet_security
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/28"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "firewall" {
  name                 = var.snet_firewall
  resource_group_name  = azurerm_resource_group.networking.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.5.0/26"]
  depends_on           = [azurerm_virtual_network.vnet]
}

/*******************************************************************************
                         CREATE STORAGE ACCOUNT
*******************************************************************************/
#This will need locking down per your requirements

resource "azurerm_storage_account" "diagnostics" {
  name                     = var.sa_diag
  resource_group_name      = var.rg_storage
  location                 = var.location
  account_tier             = var.sa_tier
  account_replication_type = var.sa_replication
  min_tls_version = var.sa_tls
}

/*******************************************************************************
                         CREATE VIRTUAL MACHINE
*******************************************************************************/

resource "azurerm_windows_virtual_machine" "win_vm_1" {
  name                = var.win_1_vm_name
  resource_group_name = var.rg_compute
  location = var.location
  size                = var.win_1_vm_size
  admin_username      = var.win_1_admin_un
  admin_password      = "${random_password.resource.result}" # Sensitive by default
  # hotpatching_enabled = true #Can be enabled if OS supports it
  # patch_mode = "AutomaticByPlatform" #Can be enabled if OS supports it
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = var.win_1_os_disk_cache
    storage_account_type = var.win_1_os_disk_sa_type
  }

  source_image_reference {
    publisher = var.win_1_source_image_publisher
    offer     = var.win_1_source_image_offer
    sku       = var.win_1_source_image_sku
    version   = var.win_1_source_image_version
  }
  boot_diagnostics {
    storage_account_uri = "${azurerm_storage_account.diagnostics.primary_blob_endpoint}"

  }

  depends_on = [azurerm_network_interface.vm_nic, azurerm_storage_account.diagnostics]
}

resource "azurerm_network_interface" "vm_nic" {
  name                = var.win_1_nic
  location = var.location
  resource_group_name = var.rg_compute

  ip_configuration {
    name                          = var.win_1_ip_internal
    subnet_id                     = azurerm_subnet.compute.id
    private_ip_address_allocation = var.win_1_pip_allocation
  }
}

/*******************************************************************************
                         CREATE NETWORK SECURITY GROUP
*******************************************************************************/

resource "azurerm_network_security_group" "nsg_1" {
  name                = var.nsg_1_name
  location = var.location
  resource_group_name = var.rg_networking

# Create your Security Rules to suit your requirements

#   security_rule {
#     name                       = "test123"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
}

resource "azurerm_network_interface_security_group_association" "nsg1_vm1" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_1.id
}

/*******************************************************************************
                         CREATE FIREWALL
*******************************************************************************/

resource "azurerm_public_ip" "firewall_pubip" {
  name                = var.firewall_pubip_name
  location = var.location
  resource_group_name = var.rg_networking
  allocation_method   = var.firewall_pubip_allocation
  sku                 = var.firewall_pubip_sku
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location = var.location
  resource_group_name = var.rg_networking
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier

  ip_configuration {
    name                 = var.firewall_ipconfig_name
    subnet_id            = azurerm_subnet.firewall.id  
    public_ip_address_id = azurerm_public_ip.firewall_pubip.id
  }

  firewall_policy_id = "${azurerm_firewall_policy.firewall_policy.id}"
  threat_intel_mode = var.fw_threat_intel_mode
  depends_on = [ azurerm_firewall_policy.firewall_policy ]
}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = var.fw_policy_name
  resource_group_name = var.rg_networking
  location = var.location
}

/*******************************************************************************
                         CREATE DDoS
*******************************************************************************/

resource "azurerm_network_ddos_protection_plan" "ddos_std" {
  name                = var.ddos_name
  location = var.location
  resource_group_name = var.rg_security
}

/*******************************************************************************
                         CREATE ALERTS
*******************************************************************************/

/***************** SUBSCRIPTION ************************/
data "azurerm_subscription" "current" {}

/***************** ACTION GROUPS ************************/
#Used to send emails to your ITSM to create cases
resource "azurerm_monitor_action_group" "ag_itsm" {
  name                = var.ag_itsm_name
  resource_group_name = var.rg_monitoring
  short_name          = var.ag_itsm_shortname
  
  email_receiver {
    name          = var.ag_itsm_email_reciever_name
    email_address = var.ag_itsm_email_address #Change this to your ITSM Email address/Webhook/Connection String/ITSM Receiver, etc. Section uses Email Receiver for demo.
  }
}

#Used to email your On Call Team to make them aware of issues. Comment out if not needed.
resource "azurerm_monitor_action_group" "ag_oncall" {
  name                = var.ag_oncall_name
  resource_group_name = var.rg_monitoring
  short_name          = var.ag_oncall_shortname
  
  email_receiver {
    name          = var.ag_oncall_email_reciever_name
    email_address = var.ag_oncall_email_address #Change this to your ITSM Email address/Webhook/Connection String, etc. Section uses Email Receiver for demo.
  }
}

#Used to email your Project Mailbox to make them aware of issues. Comment out if not needed.
resource "azurerm_monitor_action_group" "ag_proj" {
  name                = var.ag_project_name
  resource_group_name = var.rg_monitoring
  short_name          = var.ag_project_shortname
  
  email_receiver {
    name          = var.ag_project_email_reciever_name
    email_address = var.ag_project_email_address #Change this to your ITSM Email address/Webhook/Connection String, etc. Section uses Email Receiver for demo.
  }
}


/***************** FIREWALLS STATIC ALERTS ************************/
module "afw-static-firewall-health" {
  source = "./modules/metric-static-alert"

  subscription_id = data.azurerm_subscription.current.subscription_id
  resourceType    =  var.alert_resourceType_mn_fw
 
  alertName             = "Deploy-AFW-FirewallHealth"
  alertResourceGroup    = var.rg_monitoring
  alertSeverity         = "0"
  alertWindowSize       = "PT5M"
  alertFrequency        = "PT1M"
  criteria_Aggregation  = "Average"
  criteria_MetricName   = "FirewallHealth"
  criteria_Operator     = "LessThan"
  criteria_Threshold    = "90"
  
  actionGroupID = azurerm_monitor_action_group.ag_itsm.id
  
  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_Firewall || var.applyAlert_Firewall_Health) ? true : false
}

module "afw-static-snat-port-utilization"  {
  source  ="./modules/metric-static-alert"

  subscription_id = "${data.azurerm_subscription.current.subscription_id}"
  resourceType    =  var.alert_resourceType_mn_fw
 
  alertName             = "Deploy-AFW-SNATPortUtilization"
  alertResourceGroup    = var.rg_monitoring
  alertSeverity         = "1"
  alertWindowSize       = "PT5M"
  alertFrequency        = "PT1M"
  criteria_Aggregation  = "Average"
  criteria_MetricName   = "SNATPortUtilization"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "80"

  actionGroupID = azurerm_monitor_action_group.ag_itsm.id
  
  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_Firewall || var.applyAlert_Firewall_PortUtilization) ? true : false

}

/***************** FIREWALL ACTIVITY LOG ALERTS *******************/

module "afw-activity-firewall-deleted"  {
  source          ="./modules/monitor-activity-log-alert"

  subscription_id = "${data.azurerm_subscription.current.subscription_id}"
  resourceType    =  var.alert_resourceType_mn_fw
  alertName             ="ActivityAzureFirewallDelete"
  alertResourceGroup    = var.rg_monitoring

  criteria_OperationName   = "Microsoft.Network/azureFirewalls/delete"

  actionGroupID = "${azurerm_monitor_action_group.ag_proj.id}"

  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_Firewall || var.applyAlert_Firewall_Deleted) ? true : false
}

/***************** PUBLIC IP ADDRESS STATIC ALERTS ************************/

module "pip-static-bytes-in-ddos-attack" {
  source = "./modules/metric-static-alert"

  subscription_id = data.azurerm_subscription.current.subscription_id
  resourceType    =  var.alert_resourceType_mn_pip
 
  alertName             = "PIP-Bytes-in-DDOS-Attack"
  alertResourceGroup    = var.rg_monitoring
  alertSeverity         = "4"
  alertWindowSize       = "PT5M"
  alertFrequency        = "PT5M"
  criteria_Aggregation  = "Maximum"
  criteria_MetricName   = "bytesinddos"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "8000000"

  actionGroupID = azurerm_monitor_action_group.ag_itsm.id
  
  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_PrivateIP || var.applyAlert_PrivateIP_BytesInDDOSAttack) ? true : false
}

module "pip-static-ddos-attack"  {
  source          ="./modules/metric-static-alert"
 
  subscription_id = "${data.azurerm_subscription.current.subscription_id}"
  resourceType    =  var.alert_resourceType_mn_pip
 
  alertName             = "PIP-DDoS-Attack"
  alertResourceGroup    = var.rg_monitoring
  alertSeverity         = "1"
  alertWindowSize       = "PT5M"
  alertFrequency        = "PT5M"
  criteria_Aggregation  = "Maximum"
  criteria_MetricName   = "ifunderddosattack"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "0"

  actionGroupID = azurerm_monitor_action_group.ag_itsm.id
  
  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_PrivateIP || var.applyAlert_PrivateIP_DDOSAttack) ? true : false
}

module "pip-static-packets-in-ddos"  {
  source          ="./modules/metric-static-alert"
 
  subscription_id = "${data.azurerm_subscription.current.subscription_id}"
  resourceType    =  var.alert_resourceType_mn_pip
 
  alertName             = "PIP-Packets-in-DDoS-Attack"
  alertResourceGroup    = var.rg_monitoring
  alertSeverity         = "4"
  alertWindowSize       = "PT5M"
  alertFrequency        = "PT5M"
  criteria_Aggregation  = "Total"
  criteria_MetricName   = "PacketsInDDoS"
  criteria_Operator     = "GreaterThanOrEqual"
  criteria_Threshold    = "40000"

  actionGroupID = azurerm_monitor_action_group.ag_itsm.id
  
  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_PrivateIP || var.applyAlert_PrivateIP_PacketsInDDOSAttack) ? true : false
}

/***************** VIRTUAL NETWORK STATIC ALERTS ************************/

module "vnet-static-ddos-attack" {
  source = "./modules/metric-static-alert"

  subscription_id = data.azurerm_subscription.current.subscription_id
  resourceType    =  var.alert_resourceType_mn_vn
 
  alertName             = "VNet-DDos-Attack"
  alertResourceGroup    = var.rg_monitoring
  alertSeverity         = "1"
  alertWindowSize       = "PT5M"
  alertFrequency        = "PT1M"
  criteria_Aggregation  = "Maximum"
  criteria_MetricName   = "ifunderddosattack"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "0"
  
  actionGroupID = azurerm_monitor_action_group.ag_itsm.id
  
  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_VirtualNetwork || var.applyAlert_VirtualNetwork_DDOSAttack) ? true : false
}

/***************** STORAGE STATIC ALERTS ************************/

module "sa-static-availability"  {
  source          ="./modules/metric-static-alert"

  subscription_id = "${data.azurerm_subscription.current.subscription_id}"
  resourceType    = var.alert_resourceType_ms_sa
 
  alertName             = "SA-Availability"
  alertResourceGroup    = var.rg_monitoring
  alertSeverity         = "1"
  alertWindowSize       = "PT5M"
  alertFrequency        = "PT5M"
  criteria_Aggregation  = "Average"
  criteria_MetricName   = "Availability"
  criteria_Operator     = "LessThan"
  criteria_Threshold    = "100"
  
  actionGroupID = azurerm_monitor_action_group.ag_itsm.id
  
  deploy_alert = (var.applyAllAlerts || var.applyAllAlerts_Storage || var.applyAlert_Storage_SAAvailability) ? true : false
}

/***************** OTHER ACTIVITY LOG ALERTS ************************/

module "nsg-activity-delete"  {
  source          ="./modules/monitor-activity-log-alert"
 
  subscription_id = "${data.azurerm_subscription.current.subscription_id}"
  resourceType    = var.alert_resourceType_mn_nsg
    
  alertName             ="ActivityNSGDelete"
  alertResourceGroup    = var.rg_monitoring

  criteria_OperationName   = "Microsoft.Network/networkSecurityGroups/delete"
  actionGroupID = "${azurerm_monitor_action_group.ag_proj.id}"

  deploy_alert =  (var.applyAllAlerts || var.applyAllAlerts_ActivityLog || var.applyAlert_ActivityLog_NSGDelete) ? true : false
}

/***************** CUSTOM INSIGHTS QUERY LOG ALERTS ************************/

module "vm-custom-data-disk-latency-alert"  {
  source                ="./modules/custom-alert"

  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMDataDiskReadLatencyAlert) ? 1 : 0
 
  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"LogicalDisk\" and Name == \"ReadLatencyMs\" | extend Disk=tostring(todynamic(\"Tags\")[\"vm.azm.ms/mountId\"]) | where Disk !in ('C:','/') | summarize AggregatedValue = avg(Val) by bin(TimeGenerated,15m), Computer, _ResourceId, Disk"
  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMDataDiskReadLatencyAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name="Computer",
                            operator = "Include",
                            values = ["*"]                       
                          },
                          {
                            name="Disk",
                            operator = "Include",
                            values = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "30"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"

}

module "vm-custom-data-disk-free-space-warning-alert"  {
  source                ="./modules/custom-alert"

  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMDataDiskFreeSpaceWarningAlert) ? 1 : 0
 
  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"LogicalDisk\"and Name == \"FreeSpacePercentage\" | extend Disk=tostring(todynamic(Tags)[\"vm.azm.ms/mountId\"]) | where Disk !in ('C:','/') | summarize AggregatedValue = avg(Val) by bin(TimeGenerated,15m), Computer, _ResourceId, Disk"
  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMDataDiskFreeSpaceWarningAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name="Computer",
                            operator = "Include",
                            values = ["*"]                       
                          },
                          {
                            name="Disk",
                            operator = "Include",
                            values = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "LessThan"
  criteria_Threshold    = "10"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-data-disk-free-space-critical-alert"  {
  source                ="./modules/custom-alert"

  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMDataDiskFreeSpaceCriticalAlert) ? 1 : 0
 
  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"LogicalDisk\" and Name == \"FreeSpacePercentage\" | extend Disk=tostring(todynamic(Tags)[\"vm.azm.ms/mountId\"]) | where Disk !in ('C:','/') | summarize AggregatedValue = avg(Val) by bin(TimeGenerated,15m), Computer, _ResourceId, Disk"
  
  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMDataDiskFreeSpaceCriticalAlert"
  alertSeverity         = "1"
  alertDimensions       = [{
                            name="Computer",
                            operator = "Include",
                            values = ["*"]                       
                          },
                          {
                            name="Disk",
                            operator = "Include",
                            values = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "LessThan"
  criteria_Threshold    = "10"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-data-disk-write-latency-alert"  {
  source                ="./modules/custom-alert"
 
  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMDataDiskWriteLatencyAlert) ? 1 : 0

  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"LogicalDisk\" and Name == \"WriteLatencyMs\" | extend Disk=tostring(todynamic(Tags)[\"vm.azm.ms/mountId\"]) | where Disk !in ('C:','/') | summarize AggregatedValue = avg(Val) by bin(TimeGenerated,15m), Computer, _ResourceId, Disk"

  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMDataDiskWriteLatencyAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name="Computer",
                            operator = "Include",
                            values = ["*"]                       
                          },
                          {
                            name="Disk",
                            operator = "Include",
                            values = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "30"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-network-read-bytes-per-sec-alert"  {
  source                ="./modules/custom-alert"
 
  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMNetworkReadBytesPerSecAlert) ? 1 : 0

  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"Network\" and Name == \"ReadBytesPerSecond\" | extend NetworkInterface=tostring(todynamic(Tags)[\"vm.azm.ms/networkDeviceId\"]) | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, NetworkInterface"
  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMNetworkReadBytesPerSecAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name      ="Computer",
                            operator  = "Include",
                            values    = ["*"]                       
                          },
                          {
                            name      ="NetworkInterface",
                            operator  = "Include",
                            values    = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "10000000"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-network-write-bytes-per-sec-alert"  {
  source                ="./modules/custom-alert"

  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMNetworkWriteBytesPerSecAlert) ? 1 : 0

  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"Network\" and Name == \"WriteBytesPerSecond\" | extend NetworkInterface=tostring(todynamic(Tags)[\"vm.azm.ms/networkDeviceId\"]) | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, NetworkInterface"

  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMNetworkWriteBytesPerSecAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name      ="Computer",
                            operator  = "Include",
                            values    = ["*"]                       
                          },
                          {
                            name      ="NetworkInterface",
                            operator  = "Include",
                            values    = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "GreaterThan"

  criteria_Threshold    = "10000000"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-os-disk-space-percentage-alert"  {
  source                ="./modules/custom-alert"

  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMOSDiskWriteLatencyAlert) ? 1 : 0
 
  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"LogicalDisk\" and Name == \"FreeSpacePercentage\" | extend Disk=tostring(todynamic(Tags)[\"vm.azm.ms/mountId\"]) | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk"

  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMOSDiskFreeSpacePercentageAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name      ="Computer",
                            operator  = "Include",
                            values    = ["*"]                       
                          },
                          {
                            name      ="Disk",
                            operator  = "Include",
                            values    = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "LessThan"
  criteria_Threshold    = "10"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"

}

module "vm-custom-os-disk-write-latency-alert"  {
  source                ="./modules/custom-alert"

  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMOSDiskWriteLatencyAlert) ? 1 : 0

  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"LogicalDisk\" and Name == \"WriteLatencyMs\" | extend Disk=tostring(todynamic(Tags)[\"vm.azm.ms/mountId\"]) | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk"

  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMOSDiskWriteLatencyAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name      ="Computer",
                            operator  = "Include",
                            values    = ["*"]                       
                          },
                          {
                            name      ="Disk",
                            operator  = "Include",
                            values    = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "50"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-processor-utilisation-warning"  {
  source                ="./modules/custom-alert"

  
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMProcessorUtilisationWarning) ? 1 : 0
 
  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"Processor\" and Name == \"UtilizationPercentage\" | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId"

  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMProcessorUtilisationWarning"
  alertSeverity         = "2"
  alertDimensions       = [
                            {
                              name      ="Computer",
                              operator  = "Include",
                              values    = ["*"]                       
                            }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "90"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-available-memory-percentage-alert"  {
  source                ="./modules/custom-alert"

    
  count = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMAvailableMemoryPercentageAlert) ? 1 : 0
 
  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"Memory\" and Name == \"AvailableMB\" | extend TotalMemory = toreal(todynamic(Tags)[\"vm.azm.ms/memorySizeMB\"]) | extend AvailableMemoryPercentage = (toreal(Val) / TotalMemory) * 100.0 | summarize AggregatedValue = avg(AvailableMemoryPercentage) by bin(TimeGenerated, 15m), Computer, _ResourceId"
  
  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMAvailableMemoryPercentageAlert"
  alertSeverity         = "2"
  alertDimensions       = [
                            {
                              name      ="Computer",
                              operator  = "Include",
                              values    = ["*"]                       
                            }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "LessThan"
  criteria_Threshold    = "10"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"
}

module "vm-custom-subscription-os-disk-read-latency-alert"  {
  source                ="./modules/custom-subscription-alert"
 
  subscription_id       = "${data.azurerm_subscription.current.subscription_id}"
  location              = azurerm_resource_group.monitoring.name
  resourceType          = var.alert_resourceType_mc_vm

  queryString           = "InsightsMetrics | where Origin == \"vm.azm.ms\" | where Namespace == \"LogicalDisk\" and Name == \"ReadLatencyMs\" | extend Disk=tostring(todynamic(Tags)[\"vm.azm.ms/mountId\"]) | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk"

  failingPeriods        = "1"
  evaluationPeriods     = "1"
  
  alertName             ="VMOSDiskReadLatencyAlert"
  alertSeverity         = "2"
  alertDimensions       = [{
                            name      ="Computer",
                            operator  = "Include",
                            values    = ["*"]                       
                          },
                          {
                            name      ="Disk",
                            operator  = "Include",
                            values    = ["*"]                       
                          }
                          ]
                         
  alertFrequency        = "PT5M"
  alertWindowSize       = "PT15M"
  alertResourceGroup    = var.rg_monitoring

  criteria_Aggregation  = "Average"
  criteria_Operator     = "GreaterThan"
  criteria_Threshold    = "30"

  actionGroupId         = "${azurerm_monitor_action_group.ag_proj.id}"

  
  deployResourceAlert = (var.applyAllAlerts || var.applyAllAlerts_VirtualMachines || var.applyAlert_VMOSDiskReadLatencyAlert) 
}


/*******************************************************************************
                                                                           
            To use this section, uncomment it and change the scopes. 
            Scopes must be configured to point to the resources.  
                                                                           
*******************************************************************************/

## Firewall Alerts

# static
# resource "azurerm_monitor_metric_alert" "afw-static-firewall-health" {
#   name                 = "afwFirewallHealth"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]
#   target_resource_type = "Microsoft.Network/azureFirewalls"
#   description          = "Insert your description here"
#   severity             = 0
#   window_size          = "PT5M"
#   frequency            = "PT1M"
#   criteria {
#     metric_name       = "FirewallHealth"
#     metric_namespace  = "Microsoft.Network/azureFirewalls"
#     aggregation       = "Average" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "LessThan"
#     threshold         = "90"
#   }

# }

# resource "azurerm_monitor_metric_alert" "afw-static-snat-port-utilisation" {
#   name                 = "snatPortUtilisation"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]
#   target_resource_type = "Microsoft.Network/azureFirewalls"
#   description          = "Insert your description here"
#   severity             = 1
#   window_size          = "PT5M"
#   frequency            = "PT1M"
#   criteria {
#     metric_name       = "SNATPortUtilisation"
#     metric_namespace  = "Microsoft.Network/azureFirewalls"
#     aggregation       = "Average" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "GreaterThan"
#     threshold         = "80"
#   }
# }

# ## Public IP Address

# # Static

# resource "azurerm_monitor_metric_alert" "pip-static-bytes-in-ddos-attack" {
#   name                 = "pipBytesInDdosAttack"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]  // Route to resource
#   target_resource_type = "Microsoft.Network/publicIPAddresses"
#   description          = "Insert your description here"
#   severity             = 4
#   window_size          = "PT5M"
#   frequency            = "PT5M"
#   criteria {
#     metric_name       = "bytesinddos"
#     metric_namespace  = "Microsoft.Network/publicIPAddresses"
#     aggregation       = "Maximum" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "GreaterThan"
#     threshold         = "8000000"
#   }
#  #  action {
#   #  action_group_id = azurerm_monitor_action_group.ag_itsm.id
#  # }
# }

# resource "azurerm_monitor_metric_alert" "pip-static-ddos-attack" {
#   name                 = "pipDdosAttack"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]  // Route to resource
#   target_resource_type = "Microsoft.Network/publicIPAddresses"
#   description          = "Insert your description here"
#   severity             = 1
#   window_size          = "PT5M"
#   frequency            = "PT5M"
#   criteria {
#     metric_name       = "ifunderddosattack"
#     metric_namespace  = "Microsoft.Network/publicIPAddresses"
#     aggregation       = "Maximum" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "GreaterThan"
#     threshold         = "0"
#   }
#  #  action {
#   #  action_group_id = azurerm_monitor_action_group.ag_itsm.id
#  # }
# }

# resource "azurerm_monitor_metric_alert" "pip-static-packets-in-ddos" {
#   name                 = "pipPacketsInDdos"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]  // Route to resource
#   target_resource_type = "Microsoft.Network/publicIPAddresses"
#   description          = "Insert your description here"
#   severity             = 4
#   window_size          = "PT5M"
#   frequency            = "PT5M"
#   criteria {
#     metric_name       = "PacketsInDDoS"
#     metric_namespace  = "Microsoft.Network/publicIPAddresses"
#     aggregation       = "Total" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "GreaterThanOrEqual"
#     threshold         = "40000"
#   }
#  #  action {
#   #  action_group_id = azurerm_monitor_action_group.ag_itsm.id
#  # }
# }

# resource "azurerm_monitor_metric_alert" "pip-static-vip-availability" {
#   name                 = "pipVipAvailability"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]  // Route to resource
#   target_resource_type = "Microsoft.Network/publicIPAddresses"
#   description          = "Insert your description here"
#   severity             = 1
#   window_size          = "PT5M"
#   frequency            = "PT1M"
#   criteria {
#     metric_name       = "vipAvailability"
#     metric_namespace  = "Microsoft.Network/publicIPAddresses"
#     aggregation       = "Average" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "LessThan"
#     threshold         = "90"
#   }
#  #  action {
#   #  action_group_id = azurerm_monitor_action_group.ag_itsm.id
#  # }
# }

# ## Virtual Network - VNet

# # Static

# resource "azurerm_monitor_metric_alert" "pvnetip-static-ddos-attack" {
#   name                 = "vnetDDoSAttack"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]  // Route to resource
#   target_resource_type = "Microsoft.Network/virtualNetworks"
#   description          = "Insert your description here"
#   severity             = 1
#   window_size          = "PT5M"
#   frequency            = "PT1M"
#   criteria {
#     metric_name       = "ifunderddosattack"
#     metric_namespace  = "Microsoft.Network/virtualNetworks"
#     aggregation       = "Maximum" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "GreaterThan"
#     threshold         = "0"
#   }
#  #  action {
#   #  action_group_id = azurerm_monitor_action_group.ag_itsm.id
#  # }
# }

# ## Storage

# # static

# resource "azurerm_monitor_metric_alert" "sa-static-availability" {
#   name                 = "saAvailability"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]  // Route to resource
#   target_resource_type = "Microsoft.Storage/storageAccounts"
#   description          = "Insert your description here"
#   severity             = 1
#   window_size          = "PT5M"
#   frequency            = "PT5M"
#   criteria {
#     metric_name       = "Availability"
#     metric_namespace  = "Microsoft.Storage/storageAccounts"
#     aggregation       = "Average" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "LessThan"
#     threshold         = "100"
#   }
#  #  action {
#   #  action_group_id = azurerm_monitor_action_group.ag_itsm.id
#  # }
# }

# resource "azurerm_monitor_metric_alert" "sa-static-throttling" {
#   name                 = "saThrottling"
#   resource_group_name  = "dacat-alerts"
#   scopes               = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegroupname/providers/Microsoft.Network/azureFirewalls/asset.name"]  // Route to resource
#   target_resource_type = "Microsoft.Storage/storageAccounts/fileServices"
#   description          = "Insert your description here"
#   severity             = 2
#   window_size          = "PT15M"
#   frequency            = "PT5M"
#   criteria {
#     metric_name       = "Transactions"
#     metric_namespace  = "Microsoft.Storage/storageAccounts/fileServices"
#     aggregation       = "Total" #"message":"Time aggregation must be one of [Average, Maximum].
#     operator          = "GreaterThanOrEqual"
#     threshold         = "1"
#   }
#  #  action {
#   #  action_group_id = azurerm_monitor_action_group.ag_itsm.id
#  # }
# }


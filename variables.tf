/*******************************************************************************
                         LOCATION
*******************************************************************************/

# For ease, all resources here will deploy to uksouth so one variable will be
# used.
# If you need to deploy resources into different locations, create variables 
# for those resource locations. 

variable "location" {
  description = "The name location where resources will be created"
  type        = string
  default     = "uksouth"
}


/*******************************************************************************
                         RESOURCE GROUPS
*******************************************************************************/
variable "rg_compute" {
  description = "The name of the resource group for Compute resources"
  type        = string
  default     = "rg-uks-compute"
}

variable "rg_networking" {
  description = "The name of the resource group for networking resources"
  type        = string
  default     = "rg-uks-networking"
}

variable "rg_storage" {
  description = "The name of the resource group for storage resources"
  type        = string
  default     = "rg-uks-storage"
}

variable "rg_monitoring" {
  description = "The name of the resource group for monitoring resources"
  type        = string
  default     = "rg-uks-monitoring"
}

variable "rg_security" {
  description = "The name of the resource group for security resources"
  type        = string
  default     = "rg-uks-security"
}


/*******************************************************************************
                         VIRTUAL NETWORKS
*******************************************************************************/

variable "vnet_main" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "vnet-uks-main"
}

variable "snet_compute" {
  description = "The name of the Compute subnet"
  type        = string
  default     = "snet-uks-compute"
}

variable "snet_storage" {
  description = "The name of the Storage subnet"
  type        = string
  default     = "snet-uks-storage"
}

variable "snet_network" {
  description = "The name of the network subnet"
  type        = string
  default     = "snet-uks-network"
}

variable "snet_security" {
  description = "The name of the network subnet"
  type        = string
  default     = "snet-uks-security"
}

variable "snet_firewall" {
  description = "The name of the firewall subnet"
  type        = string
  default     = "AzureFirewallSubnet"
}

/*******************************************************************************
                         CREATE STORAGE ACCOUNT
*******************************************************************************/

variable "sa_diag" {
  description = "The name of the Storage Account for Diagnostics"
  type        = string
  default     = "saukstestdiag01" #Format for naming - <SA><REGION><ENV><NAME><NUMBER>
}

variable "sa_tier" {
  description = "Storage Account Tier for Diagnostics"
  type        = string
  default     = "Standard"
}

variable "sa_replication" {
  description = "Storage Account Replication Type for Diagnostics"
  type        = string
  default     = "LRS"
}

variable "sa_tls" {
  description = "Storage Account Min TLS for Diagnostics"
  type        = string
  default     = "TLS1_2"
}


/*******************************************************************************
                         CREATE VIRTUAL MACHINE
*******************************************************************************/

# VM details
variable "win_1_vm_name" {
  description = "VM Name" #Format for naming - <VM>-<REGION>-<ENV>-<NAME>_<NUMBER>
  type        = string
  default     = "vm-uks-tst-vm-1"
}

variable "win_1_vm_size" {
  description = "VM Size"
  type        = string
  default     = "Standard_B2s"
}

variable "win_1_admin_un" {
  description = "Username of Admin Account" 
  type        = string
  default     = "adminuser"
}

#VM OS Disk
variable "win_1_os_disk_cache" {
  description = "What OS Disk Caching is enabled?" 
  type        = string
  default     = "ReadWrite"
}

variable "win_1_os_disk_sa_type" {
  description = "What Storage Account type is used for OS Disk Caching"
  type        = string
  default     = "Standard_LRS"
}

#VM OS Type
variable "win_1_source_image_publisher" {
  description = "Publisher of OS Image" 
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "win_1_source_image_offer" {
  description = "What type of OS Image" 
  type        = string
  default     = "WindowsServer"
}

variable "win_1_source_image_sku" {
  description = "What SKU of OS Image" 
  type        = string
  default     = "2016-Datacenter"
}

variable "win_1_source_image_version" {
  description = "What version of OS Image" 
  type        = string
  default     = "latest"
}

#VM NIC

variable "win_1_nic" {
  description = "Name of the VM NIC" #Format for naming - <NIC>-<REGION>-<ENV>-<VM-NAME>-<NUMBER>
  type        = string
  default     = "nic-uks-test-virtualmachine_1-1"
}

variable "win_1_ip_internal" {
  description = "Name of the IP Config" 
  type        = string
  default     = "internal"
}

variable "win_1_pip_allocation" {
  description = "Allocation method used for Private IP Addresses" 
  type        = string
  default     = "Dynamic"
}


/*******************************************************************************
                         NETWORK SECURITY GROUP
*******************************************************************************/

variable "nsg_1_name" {
  description = "Specifies the name of the network security group" 
  type        = string
  default     = "nsg-uks-test-virtualmachine_1-1" #Format for naming - <NSG>-<REGION>-<ENV>-<VM-NAME>-<NUMBER>
}


/*******************************************************************************
                         CREATE FIREWALL
*******************************************************************************/

#FW Public IP details
variable "firewall_pubip_name" {
  description = "Specifies the name of the Public IP used for the Firewall" 
  type        = string
  default     = "pubip-uks-test-firewall-1" #Format for naming - <PUBIP>-<UKS>-<ENV>-<FW-NAME>-<NUMBER>
}

variable "firewall_pubip_allocation" {
  description = "Specifies the IP Address allocation used for the Firewall" 
  type        = string
  default     = "Static" 
}

variable "firewall_pubip_sku" {
  description = "Specifies the SKU used for the Firewall" 
  type        = string
  default     = "Standard" 
}

#FW details
variable "firewall_name" {
  description = "Specifies the Name used for the Firewall" 
  type        = string
  default     = "fw-gbl-test-firewall" #<FW>-<GLOBAL>-<ENV>-<NAME>
}

variable "firewall_sku_name" {
  description = "Specifies the SKU Name used for the Firewall" 
  type        = string
  default     = "AZFW_VNet" 
}

variable "firewall_sku_tier" {
  description = "Specifies the SKU Tier used for the Firewall" 
  type        = string
  default     = "Standard" 
}

#FW IP Config Details
variable "firewall_ipconfig_name" {
  description = "Specifies the Name used for the Firewall IP Configuration" 
  type        = string
  default     = "configuration" 
}

#FW Threat Detection Type
variable "fw_threat_intel_mode" {
  description = "Operation mode for threat intelligence-based filtering" 
  type        = string
  default     = "Alert" # Possible values are: Off, Alert and Deny
}

variable "fw_policy_name" {
  description = "The name which should be used for this Firewall Policy" 
  type        = string
  default     = "fw-gbl-test-firewallpolicy" # Format for naming - <FW>-<REGION>-<ENV>-<FW-POLICY-NAME>
}


/*******************************************************************************
                         CREATE DDoS
*******************************************************************************/

variable "ddos_name" {
  description = "Specifies the name of the Network DDoS Protection Plan" 
  type        = string
  default     = "ddos-protection-plan"
}


/*******************************************************************************
                         ALERT VARIBLES
*******************************************************************************/

#Action Group Details

#ITSM
variable "ag_itsm_name"{
  description = "The name of the Action Group for ITSM"
  type        = string
  default     = "action-group-itsm-mailbox"
}

variable "ag_itsm_shortname"{
  description = "The short name of the Action Group for ITSM"
  type        = string
  default     = "ag-itsm"
}

variable "ag_itsm_email_reciever_name"{
  description = "The name of the Email Receiver for ITSM"
  type        = string
  default     = "itsm-group"
}

variable "ag_itsm_email_address"{
  description = "The email address for ITSM"
  type        = string
  default     = "itsm-mailbox@yourdomain.com"
}

#OnCall
variable "ag_oncall_name"{
  description = "The name of the Action Group for Oncall"
  type        = string
  default     = "action-group-oncall-mailbox"
}

variable "ag_oncall_shortname"{
  description = "The short name of the Action Group for Oncall"
  type        = string
  default     = "ag-oncall"
}

variable "ag_oncall_email_reciever_name"{
  description = "The name of the Email Receiver for Oncall"
  type        = string
  default     = "oncall-group"
}

variable "ag_oncall_email_address"{
  description = "The email address for Oncall"
  type        = string
  default     = "oncall-mailbox@yourdomain.com"
}

#Project
variable "ag_project_name"{
  description = "The name of the Action Group for Project Mailbox"
  type        = string
  default     = "action-group-oncall-mailbox"
}

variable "ag_project_shortname"{
  description = "The short name of the Action Group for Project"
  type        = string
  default     = "ag-project"
}

variable "ag_project_email_reciever_name"{
  description = "The name of the Email Receiver for Project"
  type        = string
  default     = "project-group"
}

variable "ag_project_email_address"{
  description = "The email address for Project"
  type        = string
  default     = "project-mailbox@yourdomain.com"
}

/*******************************************************************************
                         ALERT RESOURCE TYPES
*******************************************************************************/

variable "alert_resourceType_mn_fw"{
  description = "Resource Type for Microsoft.Network/azureFirewalls"
  type        = string
  default     = "Microsoft.Network/azureFirewalls"
}

variable "alert_resourceType_mn_pip"{
  description = "Resource Type for Microsoft.Network/PublicIP's"
  type        = string
  default     = "Microsoft.Network/publicIPAddresses"
}

variable "alert_resourceType_mn_vn"{
  description = "Resource Type for Microsoft.Network/virtualNetworks"
  type        = string
  default     = "Microsoft.Network/virtualNetworks"
}

variable "alert_resourceType_ms_sa"{
  description = "Resource Type for Microsoft.Storage/storageAccounts"
  type        = string
  default     = "Microsoft.Storage/storageAccounts"
}

variable "alert_resourceType_mn_nsg"{
  description = "Resource Type for Microsoft.Network/networkSecurityGroups"
  type        = string
  default     = "Microsoft.Network/networkSecurityGroups"
}

variable "alert_resourceType_mc_vm"{
  description = "Resource Type for Microsoft.Compute/virtualMachines"
  type        = string
  default     = "Microsoft.Compute/virtualMachines"
}


/*******************************************************************************
                         APPLY ALERTS
*******************************************************************************/

variable "applyAllAlerts" {
  description   = "Apply All Alerts true/false"
  type          = bool
  default       = false
}

/********* Firewall Alerts **********/

variable "applyAllAlerts_Firewall" {
  description   = "Apply All Firewall Alerts (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_Firewall_Health" {
  description   = "Apply Firewall Health Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_Firewall_PortUtilization" {
  description   = "Apply Firewall Port Utilization Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_Firewall_Deleted" {
  description   = "Apply Firewall Deleted Alert (true/false)"
  type          = bool
  default       = false
}

/********* Firewall Alerts **********/

variable "applyAllAlerts_PrivateIP" {
  description   = "Apply All Private IP Address Alerts (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_PrivateIP_BytesInDDOSAttack" {
  description   = "Apply Private IP Address Bytes in DDOS Attack Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_PrivateIP_DDOSAttack" {
  description   = "Apply Private IP Address DDOS Attack Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_PrivateIP_PacketsInDDOSAttack" {
  description   = "Apply Private IP Address Packets In DDOS Attack Alert (true/false)"
  type          = bool
  default       = false
}

/********* VM Alerts **********/

variable "applyAllAlerts_VirtualMachines" {
  description   = "Apply All virtual machine Alerts (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMDataDiskReadLatencyAlert" {
  description   = "Apply VMDataDiskReadLatencyAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMDataDiskFreeSpaceWarningAlert" {
  description   = "Apply VMDataDiskFreeSpaceWarningAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMDataDiskFreeSpaceCriticalAlert" {
  description   = "Apply VMDataDiskFreeSpaceCriticalAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMDataDiskWriteLatencyAlert" {
  description   = "Apply VMDataDiskWriteLatencyAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMNetworkReadBytesPerSecAlert" {
  description   = "Apply VMNetworkReadBytesPerSecAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMNetworkWriteBytesPerSecAlert" {
  description   = "Apply VMNetworkWriteBytesPerSecAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMOSDiskFreeSpacePercentageAlert" {
  description   = "Apply VMOSDiskFreeSpacePercentageAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMOSDiskWriteLatencyAlert" {
  description   = "Apply VMOSDiskWriteLatencyAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMProcessorUtilisationWarning" {
  description   = "Apply VMProcessorUtilisationWarning Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMAvailableMemoryPercentageAlert" {
  description   = "Apply VMAvailableMemoryPercentageAlert Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VMOSDiskReadLatencyAlert" {
  description   = "Apply VMOSDiskReadLatencyAlert Alert (true/false)"
  type          = bool
  default       = false
}

/********* VNet Alerts **********/

variable "applyAllAlerts_VirtualNetwork" {
  description   = "Apply All Virtual Network Alerts (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_VirtualNetwork_DDOSAttack" {
  description   = "Apply Virtual Network DDOS Attack Alert (true/false)"
  type          = bool
  default       = false
}

/********* Storage Alerts **********/

variable "applyAllAlerts_Storage" {
  description   = "Apply All LA Workspace Alerts (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_Storage_SAAvailability" {
  description   = "Apply Storage SA Availability Alert (true/false)"
  type          = bool
  default       = false
}

/********* Activity Log Alerts **********/

variable "applyAllAlerts_ActivityLog" {
  description   = "Apply All Activity Log Alerts (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_ActivityLog_NSGDelete" {
  description   = "Apply Activity Log NSG Delete Alert (true/false)"
  type          = bool
  default       = false
}

variable "applyAlert_ActivityLog_ActivityUDRUpdate" {
  description   = "Apply Activity Log Activity UDR Update Alert (true/false)"
  type          = bool
  default       = false
}
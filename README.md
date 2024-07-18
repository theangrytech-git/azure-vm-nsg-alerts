<B>AZURRE-VM-NSG-ALERTS</b>
<br>
<br>
<B>What's in it?</b><br>
<br>
This will deploy the following Resources:<br><br>
<b>Resource Groups</b><br>
* rg_compute<br>
* rg_networking<br>
* rg_storage<br>
* rg_monitoring<br>
* rg_security
<br>
<b>Virtual Networks</b><br>
* Vnet - vnet-uks-main<br>
* Snet - snet-uks-compute<br>
* Snet - snet-uks-storage<br>
* Snet - snet-uks-network<br>
* Snet - snet-uks-security<br>
* Snet - snet-uks-firewall<br>
<br>
<b>Storage Accounts</b><br>
* SA - saukstestdiag01<br>
<br>
<b>Virtual Machines + NIC</b><br>
* VM - vm-uks-tst-vm-1<br>
* NIC - nic-uks-test-virtualmachine_1-1<br>
<br>
<b>Network Security Groups</b><br>
* NSG - nsg-uks-test-virtualmachine_1-1<br>
<br>
<b>Firewall, Firewall Policy and Public IP</b><br>
<br>
* FW Name - fw-gbl-test-firewall (Standard Plan)<br>
* FW Policy Name - fw-gbl-test-firewallpolicy<br>
* FW Public IP - pubip-uks-test-firewall-1<br>
<br>
<b>DDoS</b><br>
* DDoS Name - ddos-protection-plan (Standard)<br>
<br>
<b>Alerts</b><br>
* A number of alerts for each resource<br>
<br>
<br>
<B>What does this code do?</b><br>
<br>
It will deploy the Resource Groups and Virtual Networks, and then deploy a Virtual Machine into the Compute Resource Groups and Subnets.<br>
It will then attach a basic NSG to the Compute network (The rules will need to be added depending on your requirements).<br>
In addition to this, an Azure Firewall and Policy will be deployed to the Network Resource Groups and Subnets (And the AzureFirewallSubnet), as
well as a Standard DDoS Plan which will attach itself to the Virtual Network to protect the resources.<br>
Azure Alerting will then be applied to all resources to alert to DdoS attacks, availability issues, latency, lack of VM Disk space, utilisation issues, <br>
and resource deletion, set to fire alerts to an Action Group (This will need altering based on your requirements.<br>

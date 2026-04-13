// ==========================================
// 1. PARAMETERS (Inputs from .bicepparam)
// ==========================================
param location string = resourceGroup().location
param adminUsername string = 'azureuser'

@description('The password for the local administrator account on all VMs.')
@secure()
param adminPassword string

// ==========================================
// 2. VARIABLES (Internal Logic & Scaling)
// ==========================================
// This array allows you to scale Spokes without rewriting code.
var spokeConfigs = [
  {
    name: 'SpokeA'
    addressPrefix: '10.1.0.0/16'
    subnetPrefix: '10.1.1.0/24'
  }
  {
    name: 'SpokeB'
    addressPrefix: '10.2.0.0/16'
    subnetPrefix: '10.2.1.0/24'
  }
]

// ==========================================
// 3. NETWORKING - THE HUB
// ==========================================
module hubVnet './modules/vnet.bicep' = {
  name: 'hubNetDeployment'
  params: {
    vnetName: 'Hub-VNet'
    vnetAddressPrefix: '10.0.0.0/16'
    subnetName: 'MgmtSubnet'
    subnetAddressPrefix: '10.0.1.0/24'
    location: location
  }
}

// ==========================================
// 4. NETWORKING - THE SPOKES (LOOP)
// ==========================================
module spokeVnets './modules/vnet.bicep' = [for spoke in spokeConfigs: {
  name: '${spoke.name}NetDeployment'
  params: {
    vnetName: '${spoke.name}-VNet'
    vnetAddressPrefix: spoke.addressPrefix
    subnetName: 'AppSubnet'
    subnetAddressPrefix: spoke.subnetPrefix
    location: location
  }
}]

// ==========================================
// 5. COMPUTE - THE VIRTUAL MACHINES
// ==========================================
// Hub Jumpbox (The only one that could eventually have a Public IP if needed)
module hubVM './modules/compute.bicep' = {
  name: 'hubVMDeployment'
  params: {
    vmName: 'Hub-Jumpbox'
    subnetId: hubVnet.outputs.subnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
  }
}

// Spoke VMs (Private servers sitting in each spoke)
module spokeVMs './modules/compute.bicep' = [for (spoke, i) in spokeConfigs: {
  name: '${spoke.name}VMDeployment'
  params: {
    vmName: '${spoke.name}-Server'
    subnetId: spokeVnets[i].outputs.subnetId
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: location
  }
}]

// ==========================================
// 6. CONNECTIVITY - VNET PEERING
// ==========================================
// Hub to Spoke A and B
module hubToSpokePeering './modules/peering.bicep' = [for (spoke, i) in spokeConfigs: {
  name: 'hub-to-${spoke.name}-peering'
  params: {
    localVnetName: hubVnet.outputs.vnetName
    remoteVnetId: spokeVnets[i].outputs.vnetId
  }
}]

// Spoke A and B back to Hub
module spokeToHubPeering './modules/peering.bicep' = [for (spoke, i) in spokeConfigs: {
  name: '${spoke.name}-to-hub-peering'
  params: {
    localVnetName: spokeVnets[i].outputs.vnetName
    remoteVnetId: hubVnet.outputs.vnetId
  }
}]

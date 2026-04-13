// modules/peering.bicep
param localVnetName string
param remoteVnetId string

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${localVnetName}/peer-to-${last(split(remoteVnetId, '/'))}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    remoteVirtualNetwork: { id: remoteVnetId }
  }
}

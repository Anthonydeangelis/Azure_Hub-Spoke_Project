param routeTableName string
param location string
param destinationCIDR string
param hubVmIp string

resource routeTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: routeTableName
  location: location
  properties: {
    routes: [
      {
        name: 'RouteThroughHub'
        properties: {
          addressPrefix: destinationCIDR
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: hubVmIp
        }
      }
    ]
  }
}

output id string = routeTable.id

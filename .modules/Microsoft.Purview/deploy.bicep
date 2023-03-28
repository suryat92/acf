@description('Name of the resource')
param purviewname string
@description('Deployment region')
param location string


resource Purview 'Microsoft.Purview/accounts@2021-07-01' = {
  name: purviewname
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
  tags: {}
  dependsOn: []
  
}

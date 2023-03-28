@description('Location for your deployment.')
param parlocation string = resourceGroup().location

@allowed([
  'true'
  'false'
])
param parallowAllConnections string

@description('\'True\' deploys an Apache Spark pool as well as a SQL pool. \'False\' does not deploy an Apache Spark pool.')
@allowed([
  'true'
  'false'
])
param parsparkDeployment string

@description('This parameter will determine the node size if SparkDeployment is true')
@allowed([
  'Small'
  'Medium'
  'Large'
])
param parsparkNodeSize string 

@description('Specify deployment type: Dev, Pre-Prod, Prod, Test. This will also be used in the naming convention.')
@allowed([
  'dev'
  'prod'
  'test'
])
param pardeploymentType string

@description('The username of the SQL Administrator')
@secure()
param parsqlAdministratorLogin string

@description('Required. The name of resource group in which the Key Vault is deployed')
param parkvResourceGroup string
param parkvName string
param parsubscription string

resource kv 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: parkvName
  scope: resourceGroup(parsubscription, parkvResourceGroup)
}

@description('The password for the SQL Administrator')
@secure()
param parsqlAdministratorLoginPassword string 

@description('Select the SKU of the SQL pool.')
@allowed([
  'DW100c'
  'DW200c'
  'DW300c'
  'DW400c'
  'DW500c'
  'DW1000c'
  'DW1500c'
  'DW2000c'
  'DW2500c'
  'DW3000c'
])
param parsku string

@description('Choose whether you want to synchronise metadata.')
param parmetadataSync bool = false

@description('Optional. The name of virtual network within which the service needs to be deployed.')
param parmanagedVirtualNetwork string

@description('Optional. The name of synapse workspace private endpoint for synapse.')
param parprivateEndpoints array

//@description('Optional. Name for synapse storage private endpoint')
//param parprivateEndpointstrg array

@description('Optional. Tagging the services')
param partags object

@description('Optional. Boolean vaule for creation of managed private endpoint for default storage account ')
param parResourceGroupName string

param parallowAllWindowsAzureIPs string

//var synapseName = 'synapse-dp-${deploymentType}-uks-01'
var dlsName_var = 'syndlsdp${pardeploymentType}uk01' 
var dlsFsName = toLower('${dlsName_var}fs1')
var workspaceName_var = 'syndp${pardeploymentType}uk01'
var sqlPoolName = 'synsqldp${pardeploymentType}uk01'
var sparkPoolName = 'sysprkdp${pardeploymentType}uk01' 


resource dlsName 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: dlsName_var
  location: parlocation
  tags: partags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    isHnsEnabled: true
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

resource dlsName_default_dlsFsName 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: '${dlsName_var}/default/${dlsFsName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    dlsName
  ]
}

resource workspaceName 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: workspaceName_var
  location: parlocation
  tags: partags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      resourceId: dlsName.id
      accountUrl: reference(dlsName_var).primaryEndpoints.dfs
      filesystem: dlsFsName
      createManagedPrivateEndpoint: true
    }
    sqlAdministratorLogin: parsqlAdministratorLogin
    sqlAdministratorLoginPassword: parsqlAdministratorLoginPassword
    managedVirtualNetwork: parmanagedVirtualNetwork
    connectivityEndpoints: {
      web: 'https://web.azuresynapse.net?workspace=%2fsubscriptions%${parsubscription}%2fresourceGroups%2f${parResourceGroupName}%2fproviders%2fMicrosoft.Synapse%2fworkspaces%2f${workspaceName_var}'
      dev: 'https://${workspaceName_var}}.dev.azuresynapse.net'
      sqlOnDemand:'${workspaceName_var}-ondemand.sql.azuresynapse.net'
      sql: '${workspaceName_var}.sql.azuresynapse.net'
    }
    publicNetworkAccess:'Enabled'
    privateEndpointConnections:parprivateEndpoints
  }
}

resource workspaceName_allowAll 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (parallowAllConnections == 'true') {
  parent: workspaceName
  name: 'AllowAll'
  //location: location
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource workspaceName_AllowAllWindowsAzureIps 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if(parallowAllWindowsAzureIPs == 'true') {
  parent: workspaceName
  name: 'AllowAllWindowsAzureIps'
  //location: location
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource workspaceName_default 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-06-01' = {
  parent: workspaceName
  name: 'default'
  //location: location
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
}

resource workspaceName_sqlPoolName 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  parent: workspaceName
  name: sqlPoolName
  location: parlocation
  tags: partags
  
  sku: {
    name: parsku
  }
  properties: {
    createMode: 'Default'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

resource workspaceName_sqlPoolName_config 'Microsoft.Synapse/workspaces/sqlPools/metadataSync@2021-06-01' = if (parmetadataSync) {
  parent: workspaceName_sqlPoolName
  name: 'config'
  //location: location
  properties: {
    enabled: parmetadataSync
  }
}

resource workspaceName_sparkPoolName 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = if (parsparkDeployment == 'true') {
  parent: workspaceName
  name: sparkPoolName
  location: parlocation
  tags: partags
  properties: {
    nodeCount: 1
    nodeSizeFamily: 'MemoryOptimized'
    nodeSize: parsparkNodeSize
    autoScale: {
      enabled: true
      minNodeCount: 1
      maxNodeCount: 2
    }
    autoPause: {
      enabled: true
      delayInMinutes: 10
    }
    sparkVersion: '2.4'
  }
}

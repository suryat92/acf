// Define a storage account resource
param location string = resourceGroup().location

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'mystrg123456789'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

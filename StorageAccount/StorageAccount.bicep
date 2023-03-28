// Define a storage account resource
resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'mystorageaccount'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

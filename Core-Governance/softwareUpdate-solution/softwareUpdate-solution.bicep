
param parSubscription string

@description('Required. Name of the Resource Group to deploy the Automation Account')
param parResourceGroupName string

@description('Required. Name of the Automation Account')
param automationAccountName string

@description('Required. Name of the Automation Account')
param parLAWorkspaceName string

@description('Optional. Location for all resources.')
param parLocation string = resourceGroup().location


resource LAW 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: parLAWorkspaceName
} 

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' existing= {
  name: automationAccountName
  }

resource LinkAutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  name: '${LAW.name}/Automation'
  properties: {
    resourceId: automationAccount.id
  }
}
 
resource Updates 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'Updates(${parLAWorkspaceName})'
  location: parLocation
  plan: {
    name: 'Updates(${parLAWorkspaceName})'
    product: 'OMSGallery/Updates'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: LAW.id
  }
}

resource VmInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'VMInsights(${parLAWorkspaceName})'
  location: parLocation
  plan: {
    name: 'VMInsights(${parLAWorkspaceName})'
    product: 'OMSGallery/VMInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: LAW.id
  }
}


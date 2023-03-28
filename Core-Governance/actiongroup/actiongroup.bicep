targetScope = 'subscription'

#disable-next-line no-unused-params

//Params RG
param parSubscription string
param parLocation string
param parResourceGroupName string
param tags object

//Params Action Group
param parAlertAgrpName string
param parAlertAgrpShortName string
param parAlertAgrpEnabled bool
param parAlertAgrpLocation string
param parEmailReceivers array =[]

resource RgAlertsAndMonitor 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: parResourceGroupName
  location: parLocation
  tags: tags
}

module ModAlertActionGroups '../modules/Microsoft.Insights/actionGroups/deploy.bicep' = {
  name: parAlertAgrpName
  scope: RgAlertsAndMonitor
  params: {
    name: parAlertAgrpName
    groupShortName: parAlertAgrpShortName
    enabled: parAlertAgrpEnabled
    location: parAlertAgrpLocation
    tags: tags
    emailReceivers: parEmailReceivers
  }
}

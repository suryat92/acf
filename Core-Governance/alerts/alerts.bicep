targetScope = 'subscription'

//Params RG
param parSubscription string
param parResourceGroupName string
param parLocation string
param tags object

//Params Alert Metric
param parAlertMetricName string
param parAlertMetricDescription string
param parAlertMetricSeverity int
param parAlertMetricEnabled bool
param parAlertMetricWindowSize string
param parAlertMetricValuationFrequency string
param parAlertMetricTargetResourceType string
param parAlertMetricTargetResourceRegion string
param parAlertMetricLocation string
param parAlertMetricCriteriaType string
param parAlertMetricAutomitigate bool
param parAlertMetricCriterias array = []
param parActionGroupName string
param parscopes array = []

resource RgAlertsAndMonitor 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: parResourceGroupName
}

module ModAlertMetrics '../modules/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  scope: RgAlertsAndMonitor
  name: parAlertMetricName
  params: {
    name: parAlertMetricName
    alertDescription: parAlertMetricDescription
    severity: parAlertMetricSeverity
    enabled: parAlertMetricEnabled
    evaluationFrequency: parAlertMetricValuationFrequency
    windowSize: parAlertMetricWindowSize
    targetResourceRegion: parAlertMetricTargetResourceRegion
    targetResourceType: parAlertMetricTargetResourceType
    tags: tags
    scopes: parscopes
    location: parAlertMetricLocation
    alertCriteriaType: parAlertMetricCriteriaType
    criterias: parAlertMetricCriterias
    autoMitigate: parAlertMetricAutomitigate
    actions: array(Actiongrouptest.id)
  }
}

resource Actiongrouptest 'Microsoft.Insights/actionGroups@2021-09-01' existing = {
  name: parActionGroupName
  scope: resourceGroup(parResourceGroupName)
}


param parSubscription string

@description('Required. Name of the Resource Group to deploy the Automation Account')
param parResourceGroupName string

@description('Required. Name of the Automation Account')
param automationAccountName string

@description('Optional. Location for all resources.')
param parLocation string = resourceGroup().location

@allowed([
  'Free'
  'Basic'
])
@description('Optional. SKU name of the account')
param skuName string = 'Basic'

@description('Optional. List of modules to be created in the automation account')
@metadata({
  name: 'Module name'
  version: 'Module version or specify latest to get the latest version'
  uri: 'Module package uri, e.g. https://www.powershellgallery.com/api/v2/package'
})
param modules array = []

@description('Optional. List of runbooks to be created in the automation account')
param runbooks array = []

@description('Optional. SAS token validity length. Usage: \'PT8H\' - valid for 8 hours; \'P5D\' - valid for 5 days; \'P1Y\' - valid for 1 year. When not provided, the SAS token will be valid for 8 hours.')
param sasTokenValidityLength string = 'PT8H'

@description('Optional. List of schedules to be created in the automation account')
param schedules array = []

@description('Optional. List of jobSchedules to be created in the automation account')
param jobSchedules array = []

@description('Optional. Configuration Details for private endpoints.')
param privateEndpoints array = []

@minValue(0)
@maxValue(365)
@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource identifier of the Diagnostic Storage Account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource identifier of Log Analytics.')
param workspaceId string = ''

@description('Optional. Resource ID of the event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param eventHubAuthorizationRuleId string = ''

@description('Optional. Name of the event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param eventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Tags of the Automation Account resource.')
param tags object = {}

@description('Optional. Time used as a basis for e.g. the schedule start date')
param baseTime string = utcNow('u')

var accountSasProperties = {
  signedServices: 'b'
  signedPermission: 'r'
  signedExpiry: dateTimeAdd(baseTime, sasTokenValidityLength)
  signedResourceTypes: 'o'
  signedProtocol: 'https'
}

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'JobLogs'
  'JobStreams'
  'DscNodeStatus'
])
param logsToEnable array = [
  'JobLogs'
  'JobStreams'
  'DscNodeStatus'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param metricsToEnable array = [
  'AllMetrics'
]

var diagnosticsLogs = [for log in logsToEnable: {
  category: log
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in metricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: automationAccountName
  location: parLocation
  
  tags: tags
  properties: {
    sku: {
      name: skuName
    }
  }


  resource automationAccount_modules 'modules@2020-01-13-preview' = [for (module, index) in modules: {
    name: module.name
    location: parLocation
    tags: tags
    properties: {
      contentLink: {
        uri: module.version == 'latest' ? '${module.uri}/${module.name}' : '${module.uri}/${module.name}/${module.version}'
        version: module.version == 'latest' ? null : module.version
      }
    }
  }]

  resource automationAccount_schedules 'schedules@2020-01-13-preview' = [for (schedule, index) in schedules: {
    name: schedule.scheduleName
    properties: {
      startTime: (empty(schedule.startTime) ? dateTimeAdd(baseTime, 'PT10M') : schedule.startTime)
      frequency: (empty(schedule.frequency) ? null : schedule.frequency)
      expiryTime: (empty(schedule.expiryTime) ? null : schedule.expiryTime)
      interval: ((0 == schedule.interval) ? null : schedule.interval)
      timeZone: (empty(schedule.timeZone) ? null : schedule.timeZone)
      advancedSchedule: (empty(schedule.advancedSchedule) ? null : schedule.advancedSchedule)
    }
  }]

  resource automationAccount_runbooks 'runbooks@2019-06-01' = [for (runbook, index) in runbooks: {
    name: runbook.runbookName
    properties: {
      runbookType: (empty(runbook.runbookType) ? null : runbook.runbookType)
      publishContentLink: {
        uri: (empty(runbook.runbookScriptUri) ? null : (empty(runbook.scriptStorageAccountId) ? 'runbook.runbookScriptUri' : 'runbook.runbookScriptUri${listAccountSas(runbook.scriptStorageAccountId, '2019-04-01', accountSasProperties).accountSasToken}'))
        version: (empty(runbook.version) ? null : runbook.version)
      }
    }
  }]

  resource automationAccount_jobSchedules 'jobSchedules@2020-01-13-preview' = [for (jobSchedule, index) in jobSchedules: {
    name: jobSchedule.jobScheduleName
    properties: {
      parameters: (empty(jobSchedule.parameters) ? null : jobSchedule.parameters)
      runbook: {
        name: jobSchedule.runbookName
      }
      runOn: (empty(jobSchedule.runOn) ? null : jobSchedule.runOn)
      schedule: {
        name: jobSchedule.scheduleName
      }
    }
    dependsOn: [
      automationAccount_schedules
      automationAccount_runbooks
    ]
  }]
}

resource automationAccount_lock 'Microsoft.Authorization/locks@2016-09-01' = if (lock != 'NotSpecified') {
  name: '${automationAccount.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: automationAccount
}

resource automationAccount_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(workspaceId)) || (!empty(eventHubAuthorizationRuleId)) || (!empty(eventHubName))) {
  name: '${automationAccount.name}-diagnosticSettings'
  properties: {
    storageAccountId: (empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId)
    workspaceId: (empty(workspaceId) ? null : workspaceId)
    eventHubAuthorizationRuleId: (empty(eventHubAuthorizationRuleId) ? null : eventHubAuthorizationRuleId)
    eventHubName: (empty(eventHubName) ? null : eventHubName)
    metrics: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? null : diagnosticsMetrics)
    logs: ((empty(diagnosticStorageAccountId) && empty(workspaceId) && empty(eventHubAuthorizationRuleId) && empty(eventHubName)) ? null : diagnosticsLogs)
  }
  scope: automationAccount
}

module automationAccount_privateEndpoints '.bicep/nested_privateEndpoint.bicep' = [for (endpoint, index) in privateEndpoints: if (!empty(privateEndpoints)) {
  name: '${uniqueString(deployment().name, parLocation)}-Automation-PrivateEndpoints-${index}'
  params: {
    privateEndpointResourceId: automationAccount.id
    privateEndpointVnetLocation: (empty(privateEndpoints) ? 'dummy' : reference(split(endpoint.subnetResourceId, '/subnets/')[0], '2020-06-01', 'Full').location)
    privateEndpointObj: endpoint
    tags: tags
  }
  dependsOn: [
    automationAccount
  ]
}]


output automationAccountName string = automationAccount.name
output automationAccountResourceId string = automationAccount.id
output automationAccountResourceGroup string = resourceGroup().name
output modules array = modules
output schedules array = schedules
output jobSchedules array = jobSchedules
output runbooks array = runbooks

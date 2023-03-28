/*

SUMMARY: This module deploys the default Azure Landing Zone Azure Policy Assignments to the Management Group Hierarchy and also assigns the relevant RBAC.
DESCRIPTION: This module deploys the default Azure Landing Zone Azure Policy Assignments to the Management Group Hierarchy and also assigns the relevant RBAC for the system-assigned Managed Identities created for policies that require them (e.g DeployIfNotExist & Modify effect policies).
AUTHOR/S: jtracey93
VERSION: 1.0.0

*/

// **Parameters**
// Parameters are used to pass in values to the various policy assignment modules.

@description('Prefix for the management group hierarchy. DEFAULT VALUE = alz')
@minLength(2)
@maxLength(10)
param parTopLevelManagementGroupID string = 'SPS'

@description('The region where the Log Analytics Workspace & Automation Account are deployed. DEFAULT VALUE = eastus')
param parLogAnalyticsWorkSpaceAndAutomationAccountLocation string = 'uksouth'

@description('Log Analytics Workspace Resource ID. - DEFAULT VALUE: Empty String ')
param parLogAnalyticsWorkspaceResourceID string = '/subscriptions/c212bc8d-1360-4b09-a552-bb8da6b9876d/resourcegroups/rg-azure-sentinel/providers/microsoft.operationalinsights/workspaces/azuresentinel'

@description('An e-mail address that you want Microsoft Defender for Cloud alerts to be sent to.')
param parMSDFCEmailSecurityContact string = 'DSAlerts@prisons.gov.scot'

@description('ID of the DdosProtectionPlan which will be applied to the Virtual Networks.  Default: Empty String')
param parDdosProtectionPlanId string = ''


// **Variables**
// Orchestration Module Variables
var varDeploymentNameWrappers = {
  basePrefix: 'ALZBicep'
  baseSuffixTenantAndManagementGroup: '${deployment().location}-${uniqueString(deployment().location, parTopLevelManagementGroupID)}'
}

var varModuleDeploymentNames = {
  modPolicyAssignmentIntRootDeployASCDFConfig: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployASCDFConfig-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployAzActivityLog: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployAzActivityLog-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployASCMonitoring: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployASCMonitoring-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployResourceDiag: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployResoruceDiag-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployVMMonitoring: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployVMMonitoring-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployVMSSMonitoring: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployVMSSMonitoring-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDenyPublicIP: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPublicIP-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDenyRDPFromInternet: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyRDPFromInet-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDenySubnetWithoutNSG: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denySubnetNoNSG-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDenyStorageHttp: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyStorageHttp-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootEnforceTLSSSL: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enforceTLSSSL-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDenyPublicEndpoints: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPublicEndpoints-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootEnableDDoSVNET: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enableDDoSVNET-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDenyIPForwarding: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyIPForward-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDeployAKSPolicy: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployAKSPolicy-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDenyPrivEscalationAKS: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPrivEscAKS-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDenyPrivContainersAKS: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPrivConAKS-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsEnforceAKSHTTPS: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enforceAKSHTTPS-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDeploySQLDBAuditing: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deploySQLDBAudit-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDeploySQLThreat: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deploySQLThreat-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLZsDeployPrivateDNSZones: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployPrivateDNS-corp-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
}

// Policy Assignments Modules Variables

var varPolicyAssignmentEnforceAKSHTTPS = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_http_ingress_aks.tmpl.json'))
}

var varPolicyAssignmentDenyIPForwarding = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/88c0b9da-ce96-4b03-9635-f29a937e2900'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_ip_forwarding.tmpl.json'))
}

var varPolicyAssignmentDenyPrivContainersAKS = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/95edb821-ddaf-4404-9732-666045e056b4'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_priv_containers_aks.tmpl.json'))
}

var varPolicyAssignmentDenyPrivEscalationAKS = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/1c6e92c9-99f0-4e55-9cf2-0c234dc48f99'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_priv_escalation_aks.tmpl.json'))
}

var varPolicyAssignmentDenyPublicEndpoints = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policySetDefinitions/Deny-PublicPaaSEndpoints'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_public_endpoints.tmpl.json'))
}

var varPolicyAssignmentDenyPublicIP = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policyDefinitions/Deny-PublicIP'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_public_ip.tmpl.json'))
}

var varPolicyAssignmentDenyRDPFromInternet = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policyDefinitions/Deny-RDP-From-Internet'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_rdp_from_internet.tmpl.json'))
}

var varPolicyAssignmentDenyStoragehttp = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_storage_http.tmpl.json'))
}

var varPolicyAssignmentDenySubnetWithoutNsg = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policyDefinitions/Deny-Subnet-Without-Nsg'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deny_subnet_without_nsg.tmpl.json'))
}

var varPolicyAssignmentDeployAKSPolicy = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/a8eff44f-8c92-45c3-a3fb-9880802d67a7'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_aks_policy.tmpl.json'))
}

var varPolicyAssignmentDeployASCMonitoring = {
  definitionID: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_asc_monitoring.tmpl.json'))
}

var varPolicyAssignmentDeployASCDFConfig = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policySetDefinitions/Deploy-ASCDF-Config'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_ascdf_config.tmpl.json'))
}

var varPolicyAssignmentDeployAzActivityLog = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_azactivity_log.tmpl.json'))
}


var varPolicyAssignmentDeployResourceDiag = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-LogAnalytics'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_resource_diag.tmpl.json'))
}

var varPolicyAssignmentDeploySQLDBAuditing = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_sql_db_auditing.tmpl.json'))
}

var varPolicyAssignmentDeploySQLThreat = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/36d49e87-48c4-4f2e-beed-ba4ed02b71f5'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_sql_threat.tmpl.json'))
}

var varPolicyAssignmentDeployVMMonitoring = {
  definitionID: '/providers/Microsoft.Authorization/policySetDefinitions/55f3eceb-5573-4f18-9695-226972c6d74a'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_vm_monitoring.tmpl.json'))
}

var varPolicyAssignmentDeployVMSSMonitoring = {
  definitionID: '/providers/Microsoft.Authorization/policySetDefinitions/75714362-cae7-409e-9b99-a8e5075b7fad'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_deploy_vmss_monitoring.tmpl.json'))
}

var varPolicyAssignmentEnableDDoSVNET = {
  definitionID: '/providers/Microsoft.Authorization/policyDefinitions/94de2ad3-e0c1-4caf-ad78-5d47bbc83d3d'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_enable_ddos_vnet.tmpl.json'))
}

var varPolicyAssignmentEnforceTLSSSL = {
  definitionID: '${varTopLevelManagementGroupResourceID}/providers/Microsoft.Authorization/policySetDefinitions/Enforce-EncryptTransit'
  libDefinition: json(loadTextContent('../../../policy/assignments/lib/policy_assignments/policy_assignment_es_enforce_tls_ssl.tmpl.json'))
}

// RBAC Role Definitions Variables - Used For Policy Assignments
var varRBACRoleDefinitionIDs = {
  owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  networkContributor: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  aksContributor: 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8'
}

// Managment Groups Varaibles - Used For Policy Assignments
var varManagementGroupIDs = {
  intRoot: parTopLevelManagementGroupID
  platform: '${parTopLevelManagementGroupID}-platform'
  platformManagement: '${parTopLevelManagementGroupID}-platform-management'
  platformConnectivity: '${parTopLevelManagementGroupID}-platform-connectivity'
  platformIdentity: '${parTopLevelManagementGroupID}-platform-identity'
  landingZones: '${parTopLevelManagementGroupID}-landingzones'
  landingZonesCorp: '${parTopLevelManagementGroupID}-landingzones-corp'
  landingZonesOnline: '${parTopLevelManagementGroupID}-landingzones-online'
  decommissioned: '${parTopLevelManagementGroupID}-decommissioned'
  sandbox: '${parTopLevelManagementGroupID}-sandbox'
}

var varTopLevelManagementGroupResourceID = '/providers/Microsoft.Management/managementGroups/${varManagementGroupIDs.intRoot}'

// **Scope**
targetScope = 'managementGroup'

// Modules - Policy Assignments - Intermediate Root Management Group
// Module - Policy Assignment - Deploy-ASCDF-Config
module modPolicyAssignmentIntRootDeployASCDFConfig '../policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDeployASCDFConfig
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeployASCDFConfig.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployASCDFConfig.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployASCDFConfig.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployASCDFConfig.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployASCDFConfig.libDefinition.properties.parameters
    parPolicyAssignmentParameterOverrides: {
      emailSecurityContact: {
        value: parMSDFCEmailSecurityContact
      }
      ascExportResourceGroupLocation: {
        value: parLogAnalyticsWorkSpaceAndAutomationAccountLocation
      }
      logAnalytics: {
        value: parLogAnalyticsWorkspaceResourceID
      }
    }
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployASCDFConfig.libDefinition.identity.type
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.owner
    ]
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployASCDFConfig.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deploy-AzActivity-Log
module modPolicyAssignmentIntRootDeployAzActivityLog '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDeployAzActivityLog
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeployAzActivityLog.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployAzActivityLog.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.parameters
    parPolicyAssignmentParameterOverrides: {
      logAnalytics: {
        value: parLogAnalyticsWorkspaceResourceID
      }
    }
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployAzActivityLog.libDefinition.identity.type
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.owner
    ]
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployAzActivityLog.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deploy-ASC-Monitoring 
module modPolicyAssignmentIntRootDeployASCMonitoring '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDeployASCMonitoring
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeployASCMonitoring.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployASCMonitoring.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployASCMonitoring.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployASCMonitoring.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployASCMonitoring.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployASCMonitoring.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployASCMonitoring.libDefinition.properties.enforcementMode
     
  }
}

// // Module - Policy Assignment - Deploy-Resource-Diag
module modPolicyAssignmentIntRootDeployResourceDiag '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDeployResourceDiag
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeployResourceDiag.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployResourceDiag.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployResourceDiag.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployResourceDiag.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployResourceDiag.libDefinition.properties.parameters
    parPolicyAssignmentParameterOverrides: {
      logAnalytics: {
        value: parLogAnalyticsWorkspaceResourceID
      }
    }
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployResourceDiag.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployResourceDiag.libDefinition.properties.enforcementMode
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.owner
    ]
     
  }
}

// Module - Policy Assignment - Deploy-VM-Monitoring
module modPolicyAssignmentIntRootDeployVMMonitoring '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDeployVMMonitoring
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeployVMMonitoring.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployVMMonitoring.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployVMMonitoring.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployVMMonitoring.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployVMMonitoring.libDefinition.properties.parameters
    parPolicyAssignmentParameterOverrides: {
      logAnalytics_1: {
        value: parLogAnalyticsWorkspaceResourceID
      }
    }
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployVMMonitoring.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployVMMonitoring.libDefinition.properties.enforcementMode
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.owner
    ]
     
  }
}

// Module - Policy Assignment - Deploy-VMSS-Monitoring
module modPolicyAssignmentIntRootDeployVMSSMonitoring '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDeployVMSSMonitoring
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeployVMSSMonitoring.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployVMSSMonitoring.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployVMSSMonitoring.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployVMSSMonitoring.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployVMSSMonitoring.libDefinition.properties.parameters
    parPolicyAssignmentParameterOverrides: {
      logAnalytics_1: {
        value: parLogAnalyticsWorkspaceResourceID
      }
    }
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployVMSSMonitoring.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployVMSSMonitoring.libDefinition.properties.enforcementMode
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.owner
    ]
     
  }
}

// Module - Policy Assignment - Deny-Public-IP
module modPolicyAssignmentIntRootDenyPublicIP '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDenyPublicIP
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenyPublicIP.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyPublicIP.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyPublicIP.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyPublicIP.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyPublicIP.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyPublicIP.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyPublicIP.libDefinition.properties.enforcementMode
     
  }
}



// Module - Policy Assignment - Deny-RDP-From-Internet
module modPolicyAssignmentIntRootDenyRDPFromInternet '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDenyRDPFromInternet
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenyRDPFromInternet.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyRDPFromInternet.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyRDPFromInternet.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyRDPFromInternet.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyRDPFromInternet.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyRDPFromInternet.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyRDPFromInternet.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deny-Subnet-Without-Nsg
module modPolicyAssignmentIntRootDenySubnetWithoutNSG '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDenySubnetWithoutNSG
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenySubnetWithoutNsg.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenySubnetWithoutNsg.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenySubnetWithoutNsg.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenySubnetWithoutNsg.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenySubnetWithoutNsg.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenySubnetWithoutNsg.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenySubnetWithoutNsg.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deny-Storage-http 
module modPolicyAssignmentIntRootDenyStorageHttp '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDenyStorageHttp
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenyStoragehttp.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyStoragehttp.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyStoragehttp.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyStoragehttp.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Enforce-TLS-SSL
module modPolicyAssignmentIntRootEnforceTLSSSL '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootEnforceTLSSSL
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentEnforceTLSSSL.definitionID
    parPolicyAssignmentName: varPolicyAssignmentEnforceTLSSSL.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentEnforceTLSSSL.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentEnforceTLSSSL.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deny-Public-Endpoints
module modPolicyAssignmentIntRootDenyPublicEndpoints '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootDenyPublicEndpoints
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenyPublicEndpoints.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyPublicEndpoints.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyPublicEndpoints.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyPublicEndpoints.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyPublicEndpoints.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyPublicEndpoints.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyPublicEndpoints.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Enable-DDoS-VNET
module modPolicyAssignmentIntRootEnableDDoSVNET '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.intRoot)
  name: varModuleDeploymentNames.modPolicyAssignmentIntRootEnableDDoSVNET
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.intRoot
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentEnableDDoSVNET.definitionID
    parPolicyAssignmentName: varPolicyAssignmentEnableDDoSVNET.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentEnableDDoSVNET.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentEnableDDoSVNET.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentEnableDDoSVNET.libDefinition.properties.parameters
    parPolicyAssignmentParameterOverrides: {
      ddosPlan: {
        value: parDdosProtectionPlanId
      }
    }
    parPolicyAssignmentIdentityType: varPolicyAssignmentEnableDDoSVNET.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentEnableDDoSVNET.libDefinition.properties.enforcementMode
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.networkContributor
    ]
     
  }
}

// // Modules - Policy Assignments - Connectivity Management Group

// Modules - Policy Assignments - Identity Management Group

// Modules - Policy Assignments - Landing Zones Management Group 
// Module - Policy Assignment - Deny-IP-Forwarding
module modPolicyAssignmentLZsDenyIPForwarding '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsDenyIPForwarding
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.landingZones
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenyIPForwarding.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyIPForwarding.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyIPForwarding.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyIPForwarding.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyIPForwarding.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyIPForwarding.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyIPForwarding.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deploy-AKS-Policy 
module modPolicyAssignmentLZsDeployAKSPolicy '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsDeployAKSPolicy
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.landingZones
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeployAKSPolicy.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeployAKSPolicy.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeployAKSPolicy.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeployAKSPolicy.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeployAKSPolicy.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeployAKSPolicy.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeployAKSPolicy.libDefinition.properties.enforcementMode
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.aksContributor
    ]
     
  }
}

// Module - Policy Assignment - Deny-Priv-Escalation-AKS 
module modPolicyAssignmentLZsDenyPrivEscalationAKS '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsDenyPrivEscalationAKS
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.landingZones
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenyPrivEscalationAKS.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyPrivEscalationAKS.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyPrivEscalationAKS.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyPrivEscalationAKS.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyPrivEscalationAKS.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyPrivEscalationAKS.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyPrivEscalationAKS.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deny-Priv-Containers-AKS 
module modPolicyAssignmentLZsDenyPrivContainersAKS '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsDenyPrivContainersAKS
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.landingZones
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDenyPrivContainersAKS.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDenyPrivContainersAKS.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDenyPrivContainersAKS.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDenyPrivContainersAKS.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDenyPrivContainersAKS.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDenyPrivContainersAKS.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDenyPrivContainersAKS.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Enforce-AKS-HTTPS 
module modPolicyAssignmentLZsEnforceAKSHTTPS '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsEnforceAKSHTTPS
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.landingZones
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentEnforceAKSHTTPS.definitionID
    parPolicyAssignmentName: varPolicyAssignmentEnforceAKSHTTPS.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentEnforceAKSHTTPS.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentEnforceAKSHTTPS.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentEnforceAKSHTTPS.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentEnforceAKSHTTPS.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentEnforceAKSHTTPS.libDefinition.properties.enforcementMode
     
  }
}

// Module - Policy Assignment - Deploy-SQL-DB-Auditing 
module modPolicyAssignmentLZsDeploySQLDBAuditing '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsDeploySQLDBAuditing
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.landingZones
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeploySQLDBAuditing.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeploySQLDBAuditing.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeploySQLDBAuditing.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeploySQLDBAuditing.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeploySQLDBAuditing.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeploySQLDBAuditing.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeploySQLDBAuditing.libDefinition.properties.enforcementMode
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.owner
    ]
     
  }
}

// Module - Policy Assignment - Deploy-SQL-Threat 
module modPolicyAssignmentLZsDeploySQLThreat '../../../policy/assignments/policyAssignmentManagementGroup.bicep' = {
  scope: managementGroup(varManagementGroupIDs.landingZones)
  name: varModuleDeploymentNames.modPolicyAssignmentLZsDeploySQLThreat
  params: {
    parManagementGroupIDs:[
      varManagementGroupIDs.landingZones
    ]
    parPolicyAssignmentDefinitionID: varPolicyAssignmentDeploySQLThreat.definitionID
    parPolicyAssignmentName: varPolicyAssignmentDeploySQLThreat.libDefinition.name
    parPolicyAssignmentDisplayName: varPolicyAssignmentDeploySQLThreat.libDefinition.properties.displayName
    parPolicyAssignmentDescription: varPolicyAssignmentDeploySQLThreat.libDefinition.properties.description
    parPolicyAssignmentParameters: varPolicyAssignmentDeploySQLThreat.libDefinition.properties.parameters
    parPolicyAssignmentIdentityType: varPolicyAssignmentDeploySQLThreat.libDefinition.identity.type
    parPolicyAssignmentEnforcementMode: varPolicyAssignmentDeploySQLThreat.libDefinition.properties.enforcementMode
    parPolicyAssignmentIdentityRoleDefinitionIDs: [
      varRBACRoleDefinitionIDs.owner
    ]
     
  }
}

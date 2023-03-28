targetScope = 'managementGroup'

param parSubscription string
param parLocation string = deployment().location
param parResourceGroupName string
param parTopLevelManagementGroupID string
param parPolicyExemptionDisplayName string
param tags object

@description('The resource Name of the policy assignment that is being exempted.')
param policyAssignmentName string

param parExemptionDescription string = ''

@allowed([
    'Mitigated'
    'Waiver'
])
param parExemptionCategory string

@description('Optional. The expiration date and time (in UTC ISO 8601 format yyyy-MM-ddTHH:mm:ssZ) of the policy exemption. e.g. 2021-10-02T03:57:00.000Z ')
param parExpiresOn string = ''


var varPolicyAssignmentId = '/providers/Microsoft.Management/managementGroups/${parTopLevelManagementGroupID}/providers/Microsoft.Authorization/policyAssignments/${policyAssignmentName}'
var varPolicyExemptionName = take(uniqueString(parPolicyExemptionDisplayName), 24)

module rg '../modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
    scope: subscription(parSubscription)
    name: 'rg'
    params: {
        name: parResourceGroupName
        location: parLocation
        tags: tags
    }
}

module policyexception '../modules/Microsoft.Authorization/policyExemptions/deploy.bicep' = {
    name: 'policyexception'
    params: {
        location: parLocation
        name: varPolicyExemptionName
        policyAssignmentId: varPolicyAssignmentId
        displayName: parPolicyExemptionDisplayName
        description: parExemptionDescription
        exemptionCategory: parExemptionCategory
        expiresOn: parExpiresOn
        subscriptionId: parSubscription
        resourceGroupName: rg.outputs.name
    }
}

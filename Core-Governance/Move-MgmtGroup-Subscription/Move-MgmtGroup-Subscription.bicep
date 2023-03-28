targetScope = 'tenant'

param parLZMgName string
param parSubscriptionIds array = []
param parParentMGid string
param parLocation string

resource parentMG 'Microsoft.Management/managementGroups@2021-04-01' existing = {
    name: parParentMGid
}

resource resNewLZMgName 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: 'SPS-landingzones-${parLZMgName}'
    properties: {
        displayName: parLZMgName
        details: {
            parent: {
                id: parentMG.id
            }
        }
    }
}

resource resSubscriptionPlacement 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = [for subscriptionId in parSubscriptionIds: {
    name: '${resNewLZMgName.name}/${subscriptionId}'
}]

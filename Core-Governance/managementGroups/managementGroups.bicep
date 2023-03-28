/*
SUMMARY: The Management Groups module deploys a management group hierarchy in a customer's tenant under the 'Tenant Root Group'.
DESCRIPTION:  Management Group hierarchy is created through a tenant-scoped Azure Resource Manager (ARM) deployment.  The hierarchy is:
    * Tenant Root Group
        * Top Level Management Group (Level1)
            * Platform (Level2)
                * Management (Level3)
                * Connectivity
                * Identity
            * Landing Zones
                * <LZ's go here - code in the LZ repo>
            * Sandbox
            * Decommissioned
*/

targetScope = 'tenant'

param parTopLevelManagementGroupID string
param CustomerTenantRootDisplayName string

// Level 1 - Top Level
resource resTopLevelMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: parTopLevelManagementGroupID
    properties: {
        displayName: CustomerTenantRootDisplayName
    }
}

// Level 2
resource resPlatformMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: '${parTopLevelManagementGroupID}-platform'
    properties: {
        displayName: 'Platform'
        details: {
            parent: {
                id: resTopLevelMG.id
            }
        }
    }
}
resource resLandingZonesMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: '${parTopLevelManagementGroupID}-landingzones'
    properties: {
        displayName: 'Landing Zones'
        details: {
            parent: {
                id: resTopLevelMG.id
            }
        }
    }
}
resource resSandboxMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: '${parTopLevelManagementGroupID}-sandbox'
    properties: {
        displayName: 'Sandbox'
        details: {
            parent: {
                id: resTopLevelMG.id
            }
        }
    }
}
resource resDecommissionedMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: '${parTopLevelManagementGroupID}-decommissioned'
    properties: {
        displayName: 'Decommissioned'
        details: {
            parent: {
                id: resTopLevelMG.id
            }
        }
    }
}

// Level 3 - Child Management Groups under PLATFORM MG
resource resPlatformManagementMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: '${parTopLevelManagementGroupID}-platform-management'
    properties: {
        displayName: 'Management'
        details: {
            parent: {
                id: resPlatformMG.id
            }
        }
    }
}
resource resPlatformConnectivityMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: '${parTopLevelManagementGroupID}-platform-connectivity'
    properties: {
        displayName: 'Connectivity'
        details: {
            parent: {
                id: resPlatformMG.id
            }
        }
    }
}
resource resPlatformIdentityMG 'Microsoft.Management/managementGroups@2021-04-01' = {
    name: '${parTopLevelManagementGroupID}-platform-identity'
    properties: {
        displayName: 'Identity'
        details: {
            parent: {
                id: resPlatformMG.id
            }
        }
    }
}

// Level 3 - Child Management Groups under LANDING ZONES are done in the LZ Repo

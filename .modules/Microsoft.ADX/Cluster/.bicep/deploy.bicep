@description('Required. The ADX Cluster name.')
param adxname string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'Dev(No SLA)_Standard_D11_v2'
  'Dev(No SLA)_Standard_E2a_v4'
  'Standard_D11_v2'
  'Standard_D12_v2'
  'Standard_D13_v2'
  'Standard_D14_v2'
  'Standard_D16d_v5'
  'Standard_D32d_v4'
  'Standard_D32d_v5'
  'Standard_DS13_v2+1TB_PS'
  'Standard_DS13_v2+2TB_PS'
  'Standard_DS14_v2+3TB_PS'
  'Standard_DS14_v2+4TB_PS'
  'Standard_E16a_v4'
  'Standard_E16ads_v5'
  'Standard_E16as_v4+3TB_PS'
  'Standard_E16as_v4+4TB_PS'
  'Standard_E16as_v5+3TB_PS'
  'Standard_E16as_v5+4TB_PS'
  'Standard_E16s_v4+3TB_PS'
  'Standard_E16s_v4+4TB_PS'
  'Standard_E16s_v5+3TB_PS'
  'Standard_E16s_v5+4TB_PS'
  'Standard_E2a_v4'
  'Standard_E2ads_v5'
  'Standard_E4a_v4'
  'Standard_E4ads_v5'
  'Standard_E64i_v3'
  'Standard_E80ids_v4'
  'Standard_E8a_v4'
  'Standard_E8ads_v5'
  'Standard_E8as_v4+1TB_PS'
  'Standard_E8as_v4+2TB_PS'
  'Standard_E8as_v5+1TB_PS'
  'Standard_E8as_v5+2TB_PS'
  'Standard_E8s_v4+1TB_PS'
  'Standard_E8s_v4+2TB_PS'
  'Standard_E8s_v5+1TB_PS'
  'Standard_E8s_v5+2TB_PS'
  'Standard_L16s'
  'Standard_L16s_v2'
  'Standard_L4s'
  'Standard_L8s'
  'Standard_L8s_v2'  
])
@description('SKU name.')
param skuname string 


@allowed([
  1
  2
  3
])
@description('SKU Capacity')
param skucapacity int
@allowed([
  'Basic'
  'Standard'
])
@description('SKU tier')
param skutier string

@allowed([
  'None'
  'SystemAssigned'
  'SystemAssigned, UserAssigned'
  'UserAssigned'
])
@description('Identity Type')
param identitytype string

@description('userAssignedIdentities')
param userAssignedIdentities object

@description('Accepted audiences')
param acceptedaudiences string

@description('List of allowed FQDNs(Fully Qualified Domain Name) for egress from Cluster.')
param allowedFqdnList string 

@description('The list of ips in the format of CIDR allowed to connect to the cluster.')
param allowedIpRangeList string

@description('A boolean value that indicates if the cluster could be automatically stopped (due to lack of data or no activity for many days).')
param enableAutoStop bool

@description('A boolean value that indicates if the clusters disks are encrypted')
param enableDiskEncryption bool

@description('A boolean value that indicates if double encryption is enabled.')
param enableDoubleEncryption bool

@description('A boolean value that indicates if the purge operations are enabled.	')
param enablePurge bool


@description('A boolean value that indicates if the streaming ingest is enabled.')
param enableStreamingIngest bool

@description('Optional. Tags of the resource.')
param tags object = {}

@allowed([
  'V2'
  'V3'
])
@description('The engine type. V3 recommended')
param engineType string

@description('The name of the key vault key.')
param keyName string

@description('	The Uri of the key vault.')
param keyVaultUri string

@description('The version of the key vault key.')
param keyVersion string

@description('The user assigned identity (ARM resource id) that has access to the key.')
param userIdentity string

@description('A boolean value that indicate if the optimized autoscale feature is enabled or not.')
param isEnabled bool

@description('	Maximum allowed instances count.')
param maximum int

@description('	Minimum allowed instances count.')
param minimum int

@description('The version of the template defined, for instance 1.')
param version int

@allowed([
  'DualStack'
  'IPv4'
])
@description('Indicates what public IP type to create - IPv4 (default), or DualStack (both IPv4 and IPv6)')
param publicIPType string

@allowed([
  'Disabled'
  'Enabled'
])
@description('Public network access to the cluster is enabled by default. When disabled, only private endpoint connection to the cluster is allowed')
param publicNetworkAccess string

@allowed([
  'Disabled'
  'Enabled'
])
@description('	Whether or not to restrict outbound network access. Value is optional but if passed in, must be Enabled or Disabled')
param restrictOutboundNetworkAccess string

@description('	GUID representing an external tenant.')
param TrustedExternalTenantValue string

@description('Virtual Cluster graduation properties')
param virtualClusterGraduationProperties string

@description('Data management service public IP address resource id.')
param dataManagementPublicIpId string

@description('Engine services public IP address resource id.')
param enginePublicIpId string

@description('	The subnet resource id.')
param subnetId string

@description('Zones')
param zones string



resource KustoCluster 'Microsoft.Kusto/clusters@2022-02-01' = {
  name: adxname
  location: location
  tags: tags
  sku: {
    capacity: skucapacity
    name: skuname
    tier: skutier
  }
  identity: {
    type: identitytype
    userAssignedIdentities: {}
  }
  properties: {
    acceptedAudiences: [
      {
        value: acceptedaudiences
      }
    ]
    allowedFqdnList: [
      allowedFqdnList
    ]
    allowedIpRangeList: [
      allowedIpRangeList
    ]
    enableAutoStop: enableAutoStop
    enableDiskEncryption: enableDiskEncryption
    enableDoubleEncryption: enableDoubleEncryption
    enablePurge: enablePurge
    enableStreamingIngest: enableStreamingIngest
    engineType: engineType
    keyVaultProperties: {
      keyName: keyName
      keyVaultUri: keyVaultUri
      keyVersion: keyVersion
      userIdentity: userIdentity
    }
    optimizedAutoscale: {
      isEnabled: isEnabled
      maximum: maximum
      minimum: minimum
      version: version
    }
    publicIPType: publicIPType
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    trustedExternalTenants: [
      {
        value: TrustedExternalTenantValue
      }
    ]
    virtualClusterGraduationProperties:virtualClusterGraduationProperties
    virtualNetworkConfiguration: {
      dataManagementPublicIpId: dataManagementPublicIpId
      enginePublicIpId: enginePublicIpId
      subnetId: subnetId
    }
  }
  zones: [
    zones
  ]
}

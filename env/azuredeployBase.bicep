param baseName string
param clusterName string
param acrName string

var appInsightsName = '${baseName}-appinsights'

resource aks 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: clusterName
  location: resourceGroup().location
  properties: {
    'dnsPrefix': 'dnsprefix'
    'agentPoolProfiles': [
      { 
          'count': 3
          'vmSize': 'Standard_DS2_v2'
          'osType': 'Linux'
          'name': 'nodepool1'
          'mode' : 'System'
      }
    ]
    'networkProfile': {
      'outboundType': 'loadBalancer'
      'loadBalancerSku': 'standard'
    }
    'aadProfile': {
      'managed': true
    }
    'servicePrincipalProfile': {
      'clientId': 'msi'
    }
  }
  'identity': {
    'type': 'SystemAssigned'
    }
}

resource monitor 'microsoft.insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: acrName  // must be globally unique
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output nodeResourceGroup string = aks.properties.nodeResourceGroup
output connectionString string = monitor.properties.ConnectionString
output acrLoginServer string = acr.properties.loginServer


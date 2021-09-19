param clusterName string
param acrName string
param logWorkspaceName string
param appInsightsName string

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
    'addonProfiles':{
      'omsagent': {
        'config': {
          'logAnalyticsWorkspaceResourceID': logworkspace.id
        }
        'enabled': true
      }
    }
  }
  'identity': {
    'type': 'SystemAssigned'
    }  
}

resource logworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logWorkspaceName
  location: resourceGroup().location
}

resource monitor 'microsoft.insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logworkspace.id
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
output acrLoginServer string = acr.properties.loginServer


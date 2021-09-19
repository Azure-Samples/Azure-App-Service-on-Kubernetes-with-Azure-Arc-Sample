param location string
param baseName string
param kubeEnvironmentId string
param customLocationId string
param imageName string
param appInsightsName string
param acrName string

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource acr 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  name: acrName
}

var acrCredentials = acr.listCredentials()

var appServPlanName = '${baseName}-appservplan'
var webAppName = '${baseName}-webapp'

resource appservplan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: appServPlanName
  location: location
  kind: 'linux,kubernetes'
  sku: {
    name: 'K1'
    tier: 'Kubernetes'
  }
  extendedLocation: {
    type: 'customLocation'
    name: customLocationId
  }
  properties: {
    kubeEnvironmentProfile: {
        id: kubeEnvironmentId
    }
  reserved: true
  }
}

resource appserv 'Microsoft.Web/sites@2021-01-15' = {
  name: webAppName
  location: location
  kind: 'linux,kubernetes,app,container'
  extendedLocation: {
    type: 'customLocation'
    name: customLocationId
  }
  properties: {
    // name: webAppName
    serverFarmId: appservplan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acr.properties.loginServer}/${imageName}'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acr.properties.loginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrCredentials.username
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrCredentials.passwords[0].value
        }
        {
          name: 'ApplicationInsights__ConnectionString'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
        }
      ]
    }          
  }
}

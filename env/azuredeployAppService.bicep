param location string
param baseName string
param kubeEnvironmentId string
param customLocationId string
param acrLoginServer string
param acrUsername string
param acrPassword string
param imageName string
param appInsightsConnectionString string

var appServPlanName = '${baseName}-appservplan'
var webAppName = '${baseName}-webapp'

resource appservplan 'microsoft.Web/serverfarms@2021-01-01' = {
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
    name: appServPlanName
    location: location
    workerSizeId: 0
    numberOfWorkers: 1
    kubeEnvironmentProfile: {
        id: kubeEnvironmentId
    }
  reserved: true
  }
}

resource appserv 'microsoft.Web/sites@2016-09-01' = {
  name: webAppName
  location: location
  kind: 'linux,kubernetes,app,container'
  extendedLocation: {
    type: 'customLocation'
    name: customLocationId
  }
  properties: {
    name: webAppName
    serverFarmId: appservplan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${imageName}'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrPassword
        }
        {
          name: 'ApplicationInsights__ConnectionString'
          value: appInsightsConnectionString
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
        }
      ]
    }          
  }
}

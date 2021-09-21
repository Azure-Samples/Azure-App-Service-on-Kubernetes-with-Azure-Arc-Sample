param apiManagementName string
param ratingsAppName string
param appInsightsName string

resource appserv 'microsoft.Web/sites@2020-12-01' existing = {
  name: ratingsAppName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource apiManagement 'Microsoft.ApiManagement/service@2020-12-01' = {
  location: resourceGroup().location
  name: apiManagementName
  sku: {
    capacity: 1
    name: 'Developer'
  }
  properties: {
    publisherEmail: 'api-publisher@contoso.com'
    publisherName: 'publisher name'
  }

  resource appInsightsLogger 'loggers' = {
    name: appInsights.name
    properties: {
      loggerType: 'applicationInsights'
      credentials: {
        instrumentationKey: appInsights.properties.InstrumentationKey
      }
    }
  }

  resource appInsightsDiagnostics 'diagnostics' = {
    name: 'applicationinsights'
    properties: {
      loggerId: appInsightsLogger.id
      logClientIp: true
    }
  }

  resource ratingsBackend 'backends@2020-12-01' = {
    name: 'ratingsBackend'
    properties: {
      protocol: 'http'
      url: 'http://${appserv.properties.defaultHostName}/ratings'
      resourceId: '${environment().resourceManager}${appserv.id}'
    }
  }

  resource ratingsGateway 'gateways@2020-12-01' = {
    name: 'ratingsGateway'
    properties: {
      locationData: {
        name: 'ArcCluster'
      }
    }
    resource gatewayApi 'apis@2020-12-01' = {
      name: ratingsApi.name
    }
  }

  resource ratingsApi 'apis@2020-12-01' = {
    name: 'ratingsApi'
    properties: {
      displayName: 'Ratings Api'
      subscriptionRequired:false
      path: 'ratings'
      protocols: [
        'http'
        'https'
      ]
    }

    resource ratingsPolicy 'policies@2020-12-01' = {
      name: 'policy'
      properties: {
        value: '<policies>\r\n  <inbound>\r\n    <base />\r\n    <set-backend-service backend-id="${ratingsBackend.name}" />\r\n  </inbound>\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <outbound>\r\n    <base />\r\n  </outbound>\r\n  <on-error>\r\n    <base />\r\n  </on-error>\r\n</policies>'
        format: 'xml'
      }
    }

    resource ratingsGetAllOperation 'operations@2020-12-01' = {
      name: 'ratingsGetAll'
      properties: {
        displayName: 'Get all ratings'
        method: 'GET'
        urlTemplate: '/*'
      }
    }
  }
}

output gatewayManagementUrl string = '${apiManagement.properties.managementApiUrl}${apiManagement.id}'
output gatewayTokenUrl string = '${environment().resourceManager}${apiManagement::ratingsGateway.id}/generateToken?api-version=2019-12-01'
output apimResourceId string = apiManagement.id



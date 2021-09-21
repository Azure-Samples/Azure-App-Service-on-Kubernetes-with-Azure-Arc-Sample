Write-Host "Provisioning APIM instance. This may take up to 40 minutes."

az deployment group create --name "${baseName}-apiMgmt" -g $groupName --template-file  azureDeployAPIM.bicep  --parameters apiManagementName=$apiManagementName ratingsAppName=${baseName}-webapp appInsightsName=$appInsightsName

$outputs = $(az deployment group show --name "${baseName}-apiMgmt" -g $groupName |  ConvertFrom-Json).properties.outputs

if (!$outputs) { Write-Host "Error loading outputs, check API Management deployment for errors"; exit 1 }

$body = "{ `
    \`"keyType\`": \`"primary\`", `
    \`"expiry\`": \`"$((Get-Date).AddDays(29).ToString('o'))\`" `
}"
$token = "GatewayKey $(az rest -m post -u $outputs.gatewayTokenUrl.value -b $body -o tsv --query value)"

$logAnalyticsCustomerId=$(az monitor log-analytics workspace show --resource-group $groupName --workspace-name $logWorkspaceName --query customerId --output tsv)
$logAnalyticsKey = $(az monitor log-analytics workspace get-shared-keys --resource-group $groupName --workspace-name $logWorkspaceName --query primarySharedKey --output tsv)

az k8s-extension create --cluster-type connectedClusters --cluster-name  $clusterName `
  --resource-group $groupName --name "${apimExtension}" --extension-type Microsoft.ApiManagement.Gateway `
  --scope namespace --target-namespace "${apimNamespace}" `
  --configuration-settings gateway.endpoint="$($outputs.gatewayManagementUrl.value)" service.type="LoadBalancer" `
  --configuration-protected-settings gateway.authKey="$token" `
  --configuration-settings monitoring.customResourceId="$($outputs.apimResourceId.value)" monitoring.workspaceId="$logAnalyticsCustomerId" `
  --configuration-protected-settings monitoring.ingestionKey="$($logAnalyticsKey)" `
  --release-train preview

$extensionId = az k8s-extension show --cluster-type connectedClusters --cluster-name  $clusterName `
  --resource-group $groupName --name "$apimExtension"  --query id -o tsv
  
# wait for the extension to fully install before proceeding.
az resource wait --ids $extensionId --custom "properties.installState!='Pending'" --api-version "2020-07-01-preview"

Write-Host "Gateway deployed: https://portal.azure.com/#resource/subscriptions/${subscriptionId}/resourceGroups/${groupname}/providers/Microsoft.ApiManagement/service/$apiManagementName/apim-gateways"

$service = (kubectl get services -n ${apimNamespace} -o=json |  ConvertFrom-Json).items[0]
$global:apiUrl = "http://$($service.status.loadBalancer.ingress[0].ip):$($service.spec.ports[0].port)/ratings/"

try {  
  $statusCode = $(Invoke-WebRequest -Uri "$apiUrl" -SkipHttpErrorCheck).StatusCode  
}  
catch {  
  try {  
    Start-Sleep -s 10; 
    $statusCode = $(Invoke-WebRequest -Uri "$apiUrl" -SkipHttpErrorCheck).StatusCode; 
  }  catch { 
    $statusCode = $_.StatusCode; 
    $errorMessage = $_; 
  } 
} 
finally {  
  if ($statusCode -eq 200)  
  {  
      Write-Host "Deployment succesfull - api available at ${apiUrl}"  
  }  
  else  
  {      
      Write-Host "Deployment failure - ${apiUrl} returned $errorMessage"  
  } 
} 

# Provision APIM instance and gateway resource. This may up to 40 minutes. 

$createResult = az deployment group create --name "${baseName}-apiMgmt" -g $groupName --template-file  azureDeployAPIM.bicep  --parameters apiManagementName=$apiManagementName ratingsAppName=${baseName}-webapp
#  for debugging, you may re-load the result using
# $createResult = az deployment group show --name "${baseName}-apiMgmt" -g $groupName

$outputs = ($createResult |  ConvertFrom-Json).properties.outputs

if (!$outputs) { Write-Host "Error loading outputs, check API Management deployment for errors"; exit 1 }

$body = "{ `
    \`"keyType\`": \`"primary\`", `
    \`"expiry\`": \`"$((Get-Date).AddDays(29).ToString('o'))\`" `
}"
$token = "GatewayKey $(az rest -m post -u $outputs.gatewayTokenUrl.value -b $body -o tsv --query value)"

az k8s-extension create --cluster-type connectedClusters --cluster-name  $clusterName `
  --resource-group $groupName --name "${apimExtension}" --extension-type Microsoft.ApiManagement.Gateway `
  --scope namespace --target-namespace "${apimNamespace}" `
  --configuration-settings gateway.endpoint="$($outputs.gatewayManagementUrl.value)" service.type="LoadBalancer" `
  --configuration-protected-settings gateway.authKey="$token" --release-train preview

$extensionId = az k8s-extension show --cluster-type connectedClusters --cluster-name  $clusterName `
  --resource-group $groupName --name "$apimExtension"  --query id -o tsv

az k8s-extension show --cluster-type connectedClusters --cluster-name  $clusterName `
  --resource-group $groupName --name "$apimExtension" 
  
# wait for the extension to fully install before proceeding.
az resource wait --ids $extensionId --custom "properties.installState!='Pending'" --api-version "2020-07-01-preview"

Write-Host "Gateway deployed: https://portal.azure.com/#resource/subscriptions/${subscriptionId}/resourceGroups/${groupname}/providers/Microsoft.ApiManagement/service/$apiManagementName/apim-gateways"

$service = (kubectl get services -n ${apimNamespace} -o=json |  ConvertFrom-Json).items[0]
$global:apiUrl = "http://$($service.status.loadBalancer.ingress[0].ip):$($service.spec.ports[0].port)/ratings/"

$statusCode = $(Invoke-WebRequest -Uri $apiUrl).StatusCode

if ($statusCode -eq 200) 
{ 
    Write-Host "Deployment succesfull - api available at ${apiUrl}" 
} 
else 
{     
    Write-Host "Deployment failure - ${apiUrl} returned $statusCode" 
}
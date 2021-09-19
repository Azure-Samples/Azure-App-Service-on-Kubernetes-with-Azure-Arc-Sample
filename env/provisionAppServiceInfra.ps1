$logAnalyticsCustomerId=$(az monitor log-analytics workspace show --resource-group $groupName --workspace-name $logWorkspaceName --query customerId --output tsv)
$logAnalyticsCustomerIdEnc = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($logAnalyticsCustomerId))

$logAnalyticsKey = $(az monitor log-analytics workspace get-shared-keys --resource-group $groupName --workspace-name $logWorkspaceName --query primarySharedKey --output tsv)
$logAnalyticsKeyEnc = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($logAnalyticsKey))

# install the App Service extension on the Arc cluster
az k8s-extension create -g $groupName `
    --name $extensionName `
    --cluster-type connectedClusters `
    -c $clusterName `
    --extension-type 'Microsoft.Web.Appservice' `
    --release-train stable `
    --auto-upgrade-minor-version true `
    --scope cluster `
    --release-namespace $appServiceNamespace `
    --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" `
    --configuration-settings "appsNamespace=${appServiceNamespace}" `
    --configuration-settings "clusterName=${kubeEnvironmentName}" `
    --configuration-settings "loadBalancerIp=${staticIp}" `
    --configuration-settings "buildService.storageClassName=default" `
    --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" `
    --configuration-settings "customConfigMap=${appServiceNamespace}/kube-environment-config" `
    --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${aksClusterGroupName}"`
    --configuration-settings "logProcessor.appLogs.destination=log-analytics" `
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.customerId=${logAnalyticsCustomerIdEnc}" `
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.sharedKey=${logAnalyticsKeyEnc}"

# extract an ID of the installed App Service extension
$extensionId=(az k8s-extension show --cluster-type connectedClusters -c $clusterName -g $groupName --name $extensionName --query id -o tsv)
# wait for the extension to fully install before proceeding.
az resource wait --ids $extensionId --custom "properties.installState!='Pending'" --api-version "2020-07-01-preview"

# create a custom location in the region selected for the resource group that houses the resources
az customlocation create -g $groupName -n $customLocationName --host-resource-id $connectedClusterId --namespace $appServiceNamespace -c $extensionId
# extract an ID of the created custom location
$global:customLocationId=(az customlocation show -g $groupName -n $customLocationName --query id -o tsv)

# create an App Service Kubernetes Environment
az appservice kube create -g $groupName -n $kubeEnvironmentName --custom-location $customLocationId --static-ip "$staticIp" --location $location
# extract an ID of the created App Service Kubernetes Environment
$global:kubeEnvironmentId=(az appservice kube show -g $groupName -n $kubeEnvironmentName --query id -o tsv)
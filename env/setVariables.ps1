$global:baseName={set_deployment_name}
$global:location="East US"
$global:groupName=$baseName

$global:aksClusterGroupName=$baseName
$global:staticIpName="${baseName}-IP"

$baseNameOnlyAlphaNumChar=($baseName -replace '[\W]')
$global:acrName="${baseNameOnlyAlphaNumChar}acr"
$acrNameIsValid=(az acr check-name -n $acrName --query "nameAvailable" -o tsv)
if ($acrNameIsValid -eq 'false') {
    # we raise a warning instead of exiting, because the user may have previously created the infrastructure and is just resetting the environment variables.
    Write-Output "Warning: ACR name is not valid, please set a more unique base name."
}

$global:subscriptionId=$(az account show --query id -o tsv)

$global:appServiceNamespace = "appservice-ns"
$global:clusterName="${baseName}-aks" 
$global:extensionName="${baseName}-appsvc-ext" 
$global:customLocationName="${baseName}-location"
$global:kubeEnvironmentName="${baseName}-kube"

$global:apiManagementName="${basename}-apim"
$global:apimNamespace="${baseName}-apim"
$global:apimExtension="${baseName}-apim-ext"
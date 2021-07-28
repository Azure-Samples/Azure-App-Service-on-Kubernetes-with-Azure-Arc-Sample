
# create a compliant AKS cluster, an Azure Container Registry instance, an Application Insights Monitoring resource, and a public static IP address
az group create -n $groupName -l $location

az deployment group create --name "${baseName}-aks" -g $aksClusterGroupName --template-file  azuredeployBase.bicep  --parameters baseName=$baseName clusterName=$clusterName acrName=$acrName --verbose  

$global:nodeResourceGroup = (az deployment group show  -g $aksClusterGroupName -n "${baseName}-aks" -o tsv --query properties.outputs.nodeResourceGroup.value)
$global:connectionString = (az deployment group show  -g $aksClusterGroupName -n "${baseName}-aks" -o tsv --query properties.outputs.connectionString.value)
$global:acrLoginServer = (az deployment group show  -g $aksClusterGroupName -n "${baseName}-aks" -o tsv --query properties.outputs.acrLoginServer.value)

az deployment group create -g $nodeResourceGroup  --name "${baseName}-IP"  --template-file azuredeployIPAddress.bicep --parameters staticIpName=$staticIpName --verbose

$global:staticIp=(az deployment group show  -g $nodeResourceGroup  -n "${baseName}-IP" -o tsv --query properties.outputs.staticIp.value)

az aks get-credentials -g $aksClusterGroupName -n $clusterName --admin

# onboard the cluster to Arc
az connectedk8s connect -g $groupName -n $clusterName

# get the Connected Cluster Id
$global:connectedClusterId=(az connectedk8s show -n $clusterName -g $groupName --query id -o tsv)
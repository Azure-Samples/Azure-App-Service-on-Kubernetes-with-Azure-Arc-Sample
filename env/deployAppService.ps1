param(
[string]$version
)

if ($version -eq "") {
    Write-Output "Please enter a build id of the image as an argument (""dev_v1"" for example)"
    EXIT 1
}

Set-Location ../src

# build and package the dotnet code in a Release mode
dotnet publish Server/Ratings.Server.csproj -o ./Publish --configuration Release

# build Dockerfile into an image passing the Connection String of created Application Insights resource
$imageName = "${baseName}:${version}" 
docker build --build-arg BUILDTIME_CONNECTION_STRING=$connectionString -t $imageName .

# login to the ACR created in provisionBaseInfra.ps1
az acr login --name $acrName

# create an alias of the image with the fully qualified path to created ACR
docker tag "docker.io/library/${imageName}" "${acrLoginServer}/${imageName}"

# push the docker image to the ACR
docker push "${acrLoginServer}/${imageName}"


# provision App Service Plan and a containerized Web App from Azure Container Registry image
$acrUsername = (az acr credential show -n $acrName -o tsv --query username) 
$acrPassword = (az acr credential show -n $acrName -o tsv --query passwords[0].value) 

Set-Location ../env
az deployment group create --name "${baseName}-appServ" -g $groupName --template-file  azuredeployAppService.bicep  --parameters location=$location baseName=$baseName kubeEnvironmentId=$kubeEnvironmentId customLocationId=$customLocationId acrLoginServer=$acrLoginServer acrUsername=$acrUsername acrPassword=$acrPassword imageName=$imageName appInsightsConnectionString=$connectionString

$global:appUrl = az webapp show -n ${baseName}-webapp -g $groupName -o tsv --query 'defaultHostName'
$statusCode = $(Invoke-WebRequest -Uri $appUrl).StatusCode

if ($statusCode -eq 200) 
{ 
    Write-Host "Deployment succesfull - navigate to http://${appUrl}" 
} 
else 
{     
    Write-Host "Deployment failure - http://${appUrl} returned $statusCode" 
}

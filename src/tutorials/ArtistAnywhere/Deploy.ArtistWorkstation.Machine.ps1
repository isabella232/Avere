param (
    # Set a naming prefix for the Azure resource groups that are created by this deployment script
    [string] $resourceGroupNamePrefix = "Azure.Media.Pipeline",

    # Set the Azure region name for shared resources (e.g., Managed Identity, Key Vault, Monitor Insight, etc.)
    [string] $sharedRegionName = "WestUS2",

    # Set the Azure region name for compute resources (e.g., Image Gallery, Virtual Machines, Batch Accounts, etc.)
    [string] $computeRegionName = "EastUS",

    # Set the Azure region name for storage cache resources (e.g., HPC Cache, Storage Targets, Namespace Paths, etc.)
    [string] $cacheRegionName = "",

    # Set the Azure region name for storage resources (e.g., Storage Accounts, File Shares, Object Containers, etc.)
    [string] $storageRegionName = "EastUS",

    # Set to true to deploy Azure NetApp Files (https://docs.microsoft.com/azure/azure-netapp-files/azure-netapp-files-introduction)
    [boolean] $storageNetAppDeploy = $false,

    # The Azure shared services framework (e.g., Virtual Network, Managed Identity, Key Vault, etc.)
    [object] $sharedFramework,

    # The Azure storage and cache service resources (e.g., accounts, mounts, etc.)
    [object] $storageCache,

    # The Azure render manager
    [object] $renderManager
)

$templateDirectory = $PSScriptRoot
if (!$templateDirectory) {
    $templateDirectory = $using:templateDirectory
}

Import-Module "$templateDirectory/Deploy.psm1"

# Shared Framework
if (!$sharedFramework) {
    $sharedFramework = Get-SharedFramework $resourceGroupNamePrefix $sharedRegionName $computeRegionName $storageRegionName
}
$computeNetwork = Get-VirtualNetwork $sharedFramework.computeNetworks $computeRegionName
$managedIdentity = $sharedFramework.managedIdentity
$imageGallery = $sharedFramework.imageGallery

# Storage Cache
# if (!$storageCache) {
#     $storageCache = Get-StorageCache $sharedFramework $resourceGroupNamePrefix $computeRegionName $cacheRegionName $storageRegionName $storageNetAppDeploy
# }

$moduleDirectory = "ArtistWorkstation"

# 16 - Artist Workstation Machine
$moduleName = "16 - Artist Workstation Machine"
New-TraceMessage $moduleName $false $computeRegionName
$resourceGroupNameSuffix = ".Workstation"
$resourceGroupName = New-ResourceGroup $resourceGroupNamePrefix $resourceGroupNameSuffix $computeRegionName

$templateFile = "$templateDirectory/$moduleDirectory/16-Workstation.Machine.json"
$templateParameters = "$templateDirectory/$moduleDirectory/16-Workstation.Machine.Parameters.json"

$templateConfig = Get-Content -Path $templateParameters -Raw | ConvertFrom-Json
$templateConfig.parameters.managedIdentity.value.name = $managedIdentity.name
$templateConfig.parameters.managedIdentity.value.resourceGroupName = $managedIdentity.resourceGroupName
$templateConfig.parameters.imageGallery.value.name = $imageGallery.name
$templateConfig.parameters.imageGallery.value.resourceGroupName = $imageGallery.resourceGroupName

$scriptParameters = $templateConfig.parameters.scriptExtension.value.linux.scriptParameters
$scriptParameters.RENDER_MANAGER_HOST = $renderManager.host
$fileParameters = Get-ObjectProperties $scriptParameters $false
$templateConfig.parameters.scriptExtension.value.linux.fileParameters = $fileParameters

$scriptParameters = $templateConfig.parameters.scriptExtension.value.windows.scriptParameters
$scriptParameters.renderManagerHost = $renderManager.host
$fileParameters = Get-ObjectProperties $scriptParameters $true
$templateConfig.parameters.scriptExtension.value.windows.fileParameters = $fileParameters

$templateConfig.parameters.virtualNetwork.value.name = $computeNetwork.name
$templateConfig.parameters.virtualNetwork.value.resourceGroupName = $computeNetwork.resourceGroupName
$templateConfig | ConvertTo-Json -Depth 6 | Out-File $templateParameters

$groupDeployment = (az deployment group create --resource-group $resourceGroupName --template-file $templateFile --parameters $templateParameters) | ConvertFrom-Json
$artistWorkstations = $groupDeployment.properties.outputs.artistWorkstations.value
New-TraceMessage $moduleName $true $computeRegionName

Write-Output -InputObject $artistWorkstations -NoEnumerate

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
    [string] $storageRegionName = "EastUS"
)

$templateDirectory = $PSScriptRoot

Import-Module "$templateDirectory/Deploy.psm1"

$sharedFramework = Get-SharedFramework $resourceGroupNamePrefix $sharedRegionName $computeRegionName $storageRegionName
ConvertTo-Json -InputObject $sharedFramework -Depth 3 | Write-Host

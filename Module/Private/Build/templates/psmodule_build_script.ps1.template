<#
.SYNOPSIS
    Builds, tests and releases the PowerShell module via Invoke-Build.
#>
[CmdletBinding()]
param
(
    # The PowerShell module information to use
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [psobject]
    $ModuleInfo,

    # The author of the module
    [Parameter(
        Mandatory = $False
    )]
    [string]
    $ModuleAuthor = 'Brownserve UK',

    # The name of the default branch
    [Parameter(
        Mandatory = $false
    )]
    [string]
    $DefaultBranch = 'main',

    # The name of the branch you are running on, this is used to work out if the release is production or pre-release
    [Parameter(
        Mandatory = $false
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $BranchName,

    # The build to run, defaults to build whereby the module is built but no testing is performed
    [Parameter(
        Mandatory = $false
    )]
    [ValidateSet('build', 'BuildImport', 'BuildPack', 'BuildImportTest', 'BuildPackTest', 'release')]
    [string]
    $Build = 'build',

    # Where the module should be published to
    [Parameter(
        Mandatory = $false
    )]
    [string[]]
    $PublishTo = @('nuget', 'PSGallery', 'GitHub'),

    # The GitHub organisation/account that owns this module
    [Parameter(
        Mandatory = $false
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubOrg = 'Brownserve-UK',
    
    # The GitHub repo that contains this module, it's needed to build up documentation URI's
    [Parameter(
        Mandatory = $true
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubRepoName,
    
    # The PAT for pushing to GitHub
    [Parameter(
        Mandatory = $false
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubPAT = $env:GitHubPAT,

    # The API key to use when publishing to a NuGet feed, this is always needed but may not always be used
    [Parameter(
        Mandatory = $false
    )]
    [string]
    $NugetFeedApiKey,

    # The API key to use when publishing to the PSGallery
    [Parameter(
        Mandatory = $false
    )]
    [string]
    $PSGalleryAPIKey
)
# Always stop on errors
$ErrorActionPreference = 'Stop'
# If we don't have a branch name then try to work it out automatically
if (!$BranchName)
{
    $BranchName = & git rev-parse --abbrev-ref HEAD
}
# If we still don't have a branch name then set it to something sensible
if (!$BranchName)
{
    $BranchName = 'preview'
}
# Depending on how we got the branch name we may need to remove the full ref
$BranchName = $BranchName -replace 'refs\/heads\/', ''

# Work out if this is a production release depending on the branch we're building from
$PreRelease = $true
if ($DefaultBranch -eq $BranchName)
{
    $PreRelease = $false
}

# If we're not passing in the module information via the parameter try to load it from our well-known file.
if (!$ModuleInfo)
{
    try
    {
        $ModuleInfo = Get-Content (Join-Path $PSScriptRoot 'ModuleInfo.json') -Raw | ConvertFrom-Json
    
    }
    catch
    {
        throw 'Failed to load module information.'
    }
    Write-Verbose "Loaded module information from ModuleInfo.json:`n$($ModuleInfo | Out-String)"
}

# Run the init script
try
{
    Write-Verbose 'Starting build script'
    $initScriptPath = Join-Path $PSScriptRoot -ChildPath '_init.ps1' | Convert-Path
    . $initScriptPath
}
catch
{
    Write-Error "Failed to init repo.`n$($_.Exception.Message)"
}

# Ensure we have everything needed to perform a release
if ($Build -eq 'release')
{
    <# Add any steps here that are required for a release #>
}

# Invoke our build task
try
{
    $BuildParams = @{
        File              = (Join-Path -Path $global:BrownserveRepoBuildTasksDirectory -ChildPath 'build_tasks.ps1' | Convert-Path)
        Task              = $Build
        BranchName        = $BranchName
        ModuleName        = $ModuleInfo.Name
        ModuleDescription = $ModuleInfo.Description
        ModuleAuthor      = $ModuleAuthor
        ModuleGuid        = $ModuleInfo.GUID
        ModuleTags        = $ModuleInfo.Tags
    }
    if ($PreRelease)
    {
        $BuildParams.Add('Prerelease', $true)
    }
    else
    {
        $BuildParams.Add('Prerelease', $false)
    }
    if ($GitHubOrg)
    {
        $BuildParams.Add('GitHubOrg', $GitHubOrg)
    }
    if ($GitHubRepoName)
    {
        $BuildParams.Add('GitHubRepoName', $GitHubRepoName)
    }
    # Add extra parameters when doing a release
    if ($Build -eq 'release')
    {
        if ($NugetFeedApiKey)
        {
            $BuildParams.Add('NugetFeedApiKey', $NugetFeedApiKey)
        }
        if ($PSGalleryAPIKey)
        {
            $BuildParams.Add('PSGalleryAPIKey', $PSGalleryAPIKey)
        }
        if ($GitHubPAT)
        {
            $BuildParams.Add('GitHubPAT', $GitHubPAT)
        }
        $BuildParams.Add('PublishTo', $PublishTo)
    }
    Write-Verbose "Invoking build: $Build"
    Invoke-Build @BuildParams -Verbose:($PSBoundParameters['Verbose'] -eq $true)
}
catch
{
    Write-Error $_.Exception.Message
}
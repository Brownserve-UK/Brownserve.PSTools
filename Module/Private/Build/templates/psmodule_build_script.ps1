<#
.SYNOPSIS
    Builds, tests and releases the PowerShell module via Invoke-Build.
#>
[CmdletBinding()]
param
(
    # The name of the Module being built
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $ModuleName,

    # The description of the module
    [Parameter(
        Mandatory = $true
    )]
    [string]
    $ModuleDescription,

    # The author of the module
    [Parameter(
        Mandatory = $False
    )]
    [string]
    $ModuleAuthor = 'Brownserve UK',

    # Any tags to add to the module
    [Parameter(Mandatory = $false)]
    [string[]]
    $ModuleTags = 'brownserve-UK',

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
    [string]
    $BranchName = 'dev',

    # The build to run, defaults to test whereby the module is built and tests are performed against it
    [Parameter(
        Mandatory = $false
    )]
    [ValidateSet('build', 'test', 'release')]
    [string]
    $Build = 'test',

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
    
    # The GitHub repo that contains this module
    [Parameter(
        Mandatory = $false
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubRepo,
    
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
# Depending on how we got the branch name we may need to remove the full ref
$BranchName = $BranchName -replace 'refs\/heads\/', ''

# Work out if this is a production release depending on the branch we're building from
$PreRelease = $true
if ($DefaultBranch -eq $BranchName)
{
    $PreRelease = $false
}

# Run the init script
try
{
    Write-Verbose 'Initialising repo'
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
        ModuleName        = $ModuleName
        ModuleDescription = $ModuleDescription
        ModuleAuthor      = $ModuleAuthor
    }
    if ($PreRelease)
    {
        $BuildParams.Add('Prerelease', $true)
    }
    else
    {
        $BuildParams.Add('Prerelease', $false)
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
        if ($GitHubOrg)
        {
            $BuildParams.Add('GitHubOrg', $GitHubOrg)
        }
        $BuildParams.Add('PublishTo', $PublishTo)
        $BuildParams.Add('GitHubRepo', $GitHubRepo)
    }
    Write-Verbose "Invoking build: $Build"
    Invoke-Build @BuildParams -Verbose:($PSBoundParameters['Verbose'] -eq $true)
}
catch
{
    Write-Error $_.Exception.Message
}
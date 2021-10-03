<#
.SYNOPSIS
    Invokes our build tasks depending on configured options
#>
[CmdletBinding()]
param
(
    # The name of the default branch
    [Parameter(
        Mandatory = $false,
        Position = 1
    )]
    [string]
    $DefaultBranch = 'main',

    # The name of the branch you are running on, this is used to work out if the release is production or pre-release
    [Parameter(
        Mandatory = $false,
        Position = 2
    )]
    [string]
    $BranchName = 'test',

    # The build to run
    [Parameter(
        Mandatory = $false,
        Position = 3
    )]
    [ValidateSet('build', 'test', 'release')]
    [string]
    $Build = 'test',

    # The nuget feed(s) to publish to
    [Parameter(
        Mandatory = $false,
        Position = 4
    )]
    [array]
    $NugetFeedsToPublishTo = @('nuget'),

    # The GitHub organisation/account to publish the release to
    [Parameter(
        Mandatory = $false,
        Position = 5
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubOrg = 'Brownserve-UK',
    
    # The GitHub repo to publish the release to
    [Parameter(
        Mandatory = $false,
        Position = 6
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubRepo = 'Brownserve.PSTools',
    
    # The PAT for pushing to GitHub
    [Parameter(
        Mandatory = $false,
        Position = 7
    )]
    [ValidateNotNullOrEmpty()]
    [string]
    $GitHubPAT = $env:GitHubPAT,

    # The API key to use when publishing to a NuGet feed, this is always needed but may not always be used
    [Parameter(
        Mandatory = $false,
        Position = 8
    )]
    [string]
    $NugetFeedApiKey = 'AnyStringWillDo'
)
# Always stop on errors
$ErrorActionPreference = 'Stop'
# Depending on how we got the branch name we may need to remove the full ref
$BranchName = $BranchName -replace 'refs\/heads\/', ''

# Work out if this is a production release
$PreRelease = $true
if ($DefaultBranch -eq $BranchName)
{
    $PreRelease = $false
}

# Run the init script
try
{
    Write-Verbose "Initialising repo"
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
    if (!$NugetFeedsToPublishTo)
    {
        throw "Must specify 'NugetFeedsToPublishTo' for a release"
    }
    if (!$GitHubPAT)
    {
        # In cloud deployments we can pass this in as a script parameter but if it's missing we can try to pull it from vault
        # This will obviously only work on-prem
        if ($env:CI)
        {
            try
            {
                Get-Vault -Path $global:RepoBinDirectory
                $GitHubPAT = (Get-VaultSecret -Path 'credentials/live/builds/brownserve_pstools').GitHubPAT
            }
            catch
            {
                Write-Error $_.Exception.Message
            }
        }
        else
        {
            throw "Must specify 'GitHubPAT' for a release"
        }
    }
}

# Invoke our build task
try
{
    $BuildParams = @{
        File            = (Join-Path -Path $global:RepoBuildTasksDirectory -ChildPath 'build_tasks.ps1' | Convert-Path)
        Task            = $Build
        BranchName      = $BranchName
        NugetFeedApiKey = $NugetFeedApiKey
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
        $BuildParams.Add('NugetFeedsToPublishTo', $NugetFeedsToPublishTo)
        $BuildParams.Add('GitHubOrg', $GitHubOrg)
        $BuildParams.Add('GitHubRepo', $GitHubRepo)
        $BuildParams.Add('GitHubPAT', $GitHubPAT)
    }
    Write-Verbose "Invoking build: $Build"
    Invoke-Build @BuildParams -Verbose:($PSBoundParameters['Verbose'] -eq $true)
}
catch
{
    Write-Error $_.Exception.Message
}
<#
.SYNOPSIS
    This script initialises this repository.
.DESCRIPTION
    Long description
#>
# We require 6.0+ due to using newer features of PowerShell
#Requires -Version 6.0
[CmdletBinding()]
param (
    # If set will disable the compatible/incompatible cmdlet output at the end of the script
    [Parameter(
        Mandatory = $false
    )]
    [switch]
    $SuppressOutput
)
# Stop on errors
$ErrorActionPreference = 'Stop'

Write-Host 'Initialising repository, please wait...'

# Store cmdlet information here so we can dump it to screen later on
$Global:BrownserveCmdlets = @()

# If we're on Teamcity set the well-known $env:CI variable, this is set on most other CI/CD providers but not Teamcity :(
if ($env:TEAMCITY_VERSION)
{
    Write-Verbose 'Running on Teamcity, setting $env:CI'
    $env:CI = $true
}
    
# Suppress output on CI/CD - it's noisy
if ($env:CI)
{
    $SuppressOutput = $true
}

# Set up the paths that are needed by this repo for builds etc.
# These are formed using the various 'Path' cmdlets (e.g. Join-Path) 
# rather than manually forming paths to ensure we are cross compatible
$Global:BrownserveRepoRootDirectory = (Resolve-Path (Get-Item $PSScriptRoot -Force).PSParentPath) | Convert-Path # -Force flag is needed to find dot folders on *.nix
$Global:BrownserveRepoBuildDirectory = $PSScriptRoot | Convert-Path
$Global:BrownserveRepoBuildTasksDirectory = (Join-Path $Global:BrownserveRepoBuildDirectory -ChildPath 'tasks') | Convert-Path
$Global:BrownserveRepoTestsDirectory = (Join-Path $Global:BrownserveRepoBuildDirectory -ChildPath 'tests') | Convert-Path
$Global:BrownserveRepoDocsDirectory = (Join-Path $Global:BrownserveRepoRootDirectory -ChildPath '.docs') | Convert-Path
$Global:BrownserveModuleDirectory = (Join-Path $Global:BrownserveRepoRootDirectory -ChildPath 'Module') | Convert-Path

# Set the repo name
try
{
    # Try to get it from git in the first instance, but failing that we'll grab it from the directory name
    $RepoName = (Split-Path (& git config --get remote.origin.url) -Leaf) -replace '\.git', ''
}
catch {}
if ($RepoName)
{
    $Global:BrownserveRepoName = $RepoName
}
else
{
    $Global:BrownserveRepoName = Split-Path $Global:BrownserveRepoRootDirectory -Leaf
}

# Set up any ephemeral directories (those that get deleted and recreated on each run)
$EphemeralPaths = @(
    ($RepoTempDirectory = Join-Path $Global:BrownserveRepoRootDirectory -ChildPath '.tmp')
    ($BrownserveRepoLogDirectory = Join-Path $RepoTempDirectory -ChildPath 'logs'),
    ($BrownserveRepoNugetPackagesDirectory = Join-Path $Global:BrownserveRepoRootDirectory -ChildPath 'packages'),
    ($BrownserveRepoBuildOutputDirectory = Join-Path $RepoTempDirectory -ChildPath 'output'),
    ($BrownserveRepoBinaryDirectory = Join-Path $RepoTempDirectory 'bin')
)

# Destroy and recreate the ephemeral paths
try
{
    Write-Verbose 'Recreating ephemeral paths'
    $EphemeralPaths | ForEach-Object {
        if ((Test-Path $_))
        {
            Remove-Item $_ -Recurse -Force -Confirm:$false | Out-Null
        }
        New-Item $_ -ItemType Directory -Force | Out-Null
    }
}
catch
{
    Write-Error $_.Exception.Message
    break
}

<#
    Now that our ephemeral paths have been created we can set their global variables
    (we couldn't do this before as Convert-Path fails if the path does not exist)
#>
$Global:BrownserveRepoLogDirectory = $BrownserveRepoLogDirectory | Convert-Path
$Global:BrownserveRepoNugetPackagesDirectory = $BrownserveRepoNugetPackagesDirectory | Convert-Path
$Global:BrownserveRepoBuildOutputDirectory = $BrownserveRepoBuildOutputDirectory | Convert-Path
$Global:BrownserveRepoBinaryDirectory = $BrownserveRepoBinaryDirectory | Convert-Path
$Global:BrownserveRepoTempDirectory = $RepoTempDirectory | Convert-Path

# We use functions from the Brownserve.PSTools module to create this module (inception music intensifies) so we always import it
# First we remove it just in case the user has a local copy installed and loaded...
if (Get-Module 'Brownserve.PSTools')
{
    try
    {
        Remove-Module 'Brownserve.PSTools' -Verbose:$false
    }
    catch
    {
        Write-Error $_.Exception.Message
        break
    }
}
Write-Verbose 'Importing Brownserve.PSTools module'
try
{
    Import-Module (Join-Path $Global:BrownserveModuleDirectory -ChildPath 'Brownserve.PSTools.psm1') `
        -Verbose:$false `
        -Force
}
catch
{
    Write-Error "Failed to import the Brownserve.PSToolsModule.`n$($_.Exception.Message)"
}

# We use paket for managing dependencies, we download paket via dotnet
try
{
    Write-Verbose 'Restoring dotnet tools'
    Invoke-NativeCommand `
        -FilePath 'dotnet' `
        -ArgumentList 'tool', 'restore' `
        -WorkingDirectory $Global:BrownserveRepoRootDirectory `
        -SuppressOutput `
        -Verbose:($PSBoundParameters['Verbose'] -eq $true)
}
catch
{
    throw "Failed to restore dotnet tools.`n$($_.Exception.Message)"
}

# Install the dependencies from paket.dependencies
try
{
    Write-Verbose 'Installing paket dependencies'
    Invoke-NativeCommand `
        -FilePath 'dotnet' `
        -ArgumentList 'paket', 'install' `
        -WorkingDirectory $Global:BrownserveRepoRootDirectory `
        -SuppressOutput `
        -Verbose:($PSBoundParameters['Verbose'] -eq $true)
}
catch
{
    throw "Failed to install paket dependencies.`n$($_.Exception.Message)"
}

# Set an alias to Nuget.exe and update an env var
# This ensures we use the local version every time
try
{
    Set-Alias -Name 'nuget' -Value (Join-Path $global:BrownserveRepoNugetPackagesDirectory 'NuGet.CommandLine' 'tools', 'NuGet.exe') -Scope Global
    $Global:BrownserveNugetPath = (Get-Command 'nuget').Definition
}
catch
{
    throw $_.Exception.Message
}

<#
    We use platyPS for generating module documentation/help files.
    As we don't want to install this globally we download the module to the 'packages' directory
#>
try
{
    Write-Verbose 'Downloading platyPS module'
    #Save-Module 'platyPS' -Repository PSGallery -Path $Global:BrownserveRepoNugetPackagesDirectory
}
catch
{
    throw "Failed to download the platyPS module.`n$($_.Exception.Message)"
}

# Now we can import all our tooling!
try
{
    Write-Verbose 'Importing external modules'
    @(
        (Join-Path $Global:BrownserveRepoNugetPackagesDirectory 'Invoke-Build' -AdditionalChildPath 'tools', 'InvokeBuild.psd1'),
        (Join-Path $Global:BrownserveRepoNugetPackagesDirectory 'Pester' -AdditionalChildPath 'tools', 'Pester.psd1')
        #(Get-ChildItem (Join-Path $Global:BrownserveRepoNugetPackagesDirectory -ChildPath 'platyPS') -Filter 'platyPS.psd1' -Recurse)
    ) | ForEach-Object {
        Import-Module $_ -Force -Verbose:$false
    }
}
catch
{
    throw $_.Exception.Message
}

Write-Host 'Repo initialised successfully!' -ForegroundColor Green

# If we're not suppressing output then we'll pipe out a list of cmdlets that are now available to the user along with
# Their synopsis. 
if (!$SuppressOutput)
{
    if ($Global:BrownserveCmdlets)
    {
        Write-Host "The following modules have been loaded and their functions are now available:`n"
        $Global:BrownserveCmdlets | ForEach-Object {
            Write-Host "$($_.Module):" -ForegroundColor Yellow
            $_.Cmdlets | ForEach-Object {
                Write-Host "    $($_.Name) " -ForegroundColor Magenta -NoNewline; Write-Host "|  $($_.Synopsis)" -ForegroundColor Blue
            }
            ''
        }
        Write-Host "For more information please use the 'Get-Help <command-name>' command`n"
    }
}
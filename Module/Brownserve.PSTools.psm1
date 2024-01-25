<#
.DESCRIPTION
    A collection of useful cmdlets, functions and tools that can be used across a variety of projects.
#>
#Requires -Version 6.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$PublicCmdlets = @()

<#
    We often store complex default values in JSON config files as this makes them easier to read and maintain, plus it allows users to easily override them using their own config files with their own values.
    While our standard configuration files containing our sensible defaults are included with the module(s) that reference them we need a place to store any user defined config files.
    We've chosen to store these in the users PowerShell profile directory as this is a well known location and is easy to get to.
    We perform this early so that if it fails we can stop the module from loading.
#>
$BrownserveProfileDirectory = Join-Path (Split-Path $PROFILE) 'Brownserve'
if (-not (Test-Path $BrownserveProfileDirectory))
{
    New-Item -Path $BrownserveProfileDirectory -ItemType Directory -Force | Out-Null
}
$BrownserveConfigsDirectory = Join-Path $BrownserveProfileDirectory 'Config'
if (-not (Test-Path $BrownserveConfigsDirectory))
{
    New-Item -Path $BrownserveConfigsDirectory -ItemType Directory -Force | Out-Null
}
$BrownservePSToolsUserConfigDirectory = Join-Path $BrownserveConfigsDirectory 'PSTools'
if (-not (Test-Path $BrownservePSToolsUserConfigDirectory))
{
    New-Item -Path $BrownservePSToolsUserConfigDirectory -ItemType Directory -Force | Out-Null
}

<#
    Once the user config directory has been created we can export it - we use a global variable so it's available to all cmdlets and other Brownserve modules.
    It's up to the cmdlets to perform the logic of checking for and using any user defined config files.
#>
$Global:BrownservePSToolsUserConfigDirectory = $BrownservePSToolsUserConfigDirectory

# Dot source our private functions so they are available for our public functions to use
$PrivatePath = Join-Path $PSScriptRoot -ChildPath 'Private'
$PrivatePath |
    Resolve-Path |
        Get-ChildItem -Filter *.ps1 -Recurse |
            ForEach-Object {
                . $_.FullName
            }

# Dot source our public functions and then add their help information to an array
Join-Path $PSScriptRoot -ChildPath 'Public' |
    Resolve-Path |
        Get-ChildItem -Filter *.ps1 -Recurse |
            ForEach-Object {
                . $_.FullName
                Export-ModuleMember $_.BaseName
                $PublicCmdlets += Get-Help $_.BaseName
            }
<#
    If our special variable exists then add these cmdlets to said variable so we can output their summary later on.
    Unfortunately just checking for the existence of the variable isn't enough as if it's blank PowerShell seems to treat it as null :(
#>
if ($Global:BrownserveCmdlets -is 'System.Array')
{
    $Global:BrownserveCmdlets += @{
        Module  = "$($MyInvocation.MyCommand)"
        Cmdlets = $PublicCmdlets
    }
}

<#
    Some cmdlets will need to make use of temporary files so we need somewhere to store them.
    _If_ we're in a repository then store them in the repositories temp location, otherwise use the system temp drive.
    (This allows us to easily get at temp files created during builds etc and means we don't have to override them in each cmdlet)
#>
$script:BrownserveTempLocation = (Get-PSDrive Temp).Root
if ($Global:BrownserveRepoTempDirectory)
{
    # Only set the path if it's valid, we don't want to set a duff path!
    if ((Test-Path $Global:BrownserveRepoTempDirectory))
    {
        $script:BrownserveTempLocation = $Global:BrownserveRepoTempDirectory
    }
    else
    {
        Write-Warning "The `$global:sBrownserveRepoTempDirectory path '$($global:BrownserveRepoTempDirectory)' does not appear to be a valid path and therefore will be ignored."
    }
}
<#
    Always set the default config directory to the one in the module directory.
#>
$Script:BrownservePSToolsConfigDirectory = Join-Path $PrivatePath '.config'

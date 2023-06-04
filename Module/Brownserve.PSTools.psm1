<#
.DESCRIPTION
    A collection of useful cmdlets, functions and tools that can be used across a variety of projects.
#>
#Requires -Version 6.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$PublicCmdlets = @()

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
    The config directory is used to store various default configurations for our cmdlets to reference
#>
$Script:BrownservePSToolsConfigDirectory = Join-Path $PrivatePath '.config'

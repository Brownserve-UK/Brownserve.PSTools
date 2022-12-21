<#
.SYNOPSIS
    A collection of useful cmdlets, functions and tools that can be used across a variety of projects.
#>
#Requires -Version 6.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

$PublicCmdlets = @()

# Dot source our private functions so they are available for our public functions to use
Join-Path $PSScriptRoot -ChildPath 'Private' |
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
        Module = "$($MyInvocation.MyCommand)"
        Cmdlets = $PublicCmdlets
    }
}
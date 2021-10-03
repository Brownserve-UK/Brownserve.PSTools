<#
.SYNOPSIS
  A collection of useful cmdlets, functions and tools that can be used across a variety of projects.
#>
#Requires -Version 6.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'

# Set platform specific variables if they do not exist 
if (-not (Test-Path variable:global:IsWindows))
{
    # If using PowerShell Desktop 5.1 and below then these variables won't exist as they were introduced in v6.0
    # Given that PowerShell Desktop is Windows only it's safe to assume we're on Windows 
    $global:IsWindows = $true
    $global:IsLinux = $false
    $global:IsMacOs = $false
    $global:OS = 'Windows'
}
else
{
    # Horrible set of conditionals for setting our OS variable :(
    if ($IsWindows)
    {
        $global:OS = 'Windows'
    }
    if ($IsLinux)
    {
        $global:OS = 'Linux'
    }
    if ($IsMacOS)
    {
        $global:OS = 'macOS'
    }
}

# We use some special variables for working out what cmdlets are compatible with a users systems
$PublicCmdlets = @()
$CompatibleCmdlets = @()
$IncompatibleCmdlets = @()


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
                $PublicCmdlets += Get-Help $_.BaseName
            }

# Go over the array we just created to see if all of our cmdlets/functions are compatible with the OS we are running
# If they are then we export it for use, if not then we do not.
$PublicCmdlets | ForEach-Object {
    $RegexMatch = [regex]::Match(($_.Description | Out-String), '\[Compatible with:(?<os>.*)\]')
    if ($RegexMatch.Success)
    {
        $CompatibleOS = $RegexMatch.Groups['os'] -split ', '
        # There are cases whereby we may want to ignore the compatibility check (such as generating help docs)
        # And export the function regardless.
        if ($global:IgnoreCmdletCompatibility)
        {
            $CompatibleOS = @('Windows','macOS','Linux')
        }
        if ($global:OS -in $CompatibleOS)
        {
            $CompatibleCmdlets += $_
        }
        else
        {
            $IncompatibleCmdlets += $_
        }
    }
    # If it doesn't have a [Compatible with: ] block then we just assume it's compatible with everything
    else
    {
        $CompatibleCmdlets += $_
    }
}

$CompatibleCmdlets | ForEach-Object {
    Export-ModuleMember $_.Name
}

<# 
  By design this module does not output our usual "The following commands are now available:" blurb,
  given the amount of functions in this module it results in some very noisy output.
  If we've got our well known $Global:BrownserveCmdlets variable it means we've used an init script
  or some other build process/wrapper so add these to the list.
#>
if ($Global:BrownserveCmdlets)
{
    $Global:BrownserveCmdlets.CompatibleCmdlets += $CompatibleCmdlets
    $Global:BrownserveCmdlets.IncompatibleCmdlets += $IncompatibleCmdlets
}
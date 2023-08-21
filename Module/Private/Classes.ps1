<#
.DESCRIPTION
    Special private classes for the module.
    Previously the module used to have a lot of private classes spread across various files, this is an attempt to consolidate them into one file.
#>


## GitHub related classes
enum GitHubPullRequestState
{
    Open
    Closed
    All
}

## Type validation classes

<#
    The System.Version type doesn't currently support semantic versioning and there's no alternative (https://github.com/dotnet/runtime/issues/19317)
    So if we've got a version with a PreRelease we can't cast it to a version object.
    This simple class evaluates a version string to ensure it's SemVer compliant.
    At a later date it might be nice to split out each part of the version
#>
class SemVer
{
    [string] $Value
    SemVer([string] $Value)
    {
        if ($Value -cnotmatch '^((([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?)$')
        {
            throw "Invalid SemVer string: $Value"
        }
        else
        {
            $this.Value = $Value     
        }
    }
}
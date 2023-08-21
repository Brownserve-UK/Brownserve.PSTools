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

# This class validates a string to be a valid SemVer string.
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
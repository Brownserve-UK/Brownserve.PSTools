<#
.DESCRIPTION
    Special private classes for the module.
    Previously the module used to have a lot of private classes spread across various files, this is an attempt to consolidate them into one file.
#>

## Git related classes

<#
    This class converts shorthand git diffs into human readable status
#>
class GitDiff
{
    [string] $Value

    GitDiff([char] $Value)
    {
        $StatusMap = @{
            '?' = 'Untracked'
            '!' = 'Ignored'
            'A' = 'Added'
            'C' = 'Copied'
            'D' = 'Deleted'
            'M' = 'Modified'
            'R' = 'Renamed'
            'T' = 'Type Changed'
            'U' = 'Unmerged'
            ' ' = 'Unmodified'
        }
        if ($StatusMap.ContainsKey($Value))
        {
            $this.Value = $StatusMap[$Value]
        }
        else
        {
            throw "Invalid git status: '$Value'"
        }
    }

    GitDiff([string] $Value)
    {
        $StatusMap = @{
            '?' = 'Untracked'
            '!' = 'Ignored'
            'A' = 'Added'
            'C' = 'Copied'
            'D' = 'Deleted'
            'M' = 'Modified'
            'R' = 'Renamed'
            'T' = 'Type Changed'
            'U' = 'Unmerged'
            ' ' = 'Unmodified'
        }
        if ($StatusMap.ContainsKey($Value))
        {
            $this.Value = $StatusMap[$Value]
        }
        else
        {
            throw "Invalid git status: '$Value'"
        }
    }

    [string] ToString()
    {
        return "$($this.Value)"
    }
}

<#
    This class is used to construct a git file object.
    Sometimes they contain a source and destination if the file is a move/rename, but should always contain a source.
#>
class GitFile
{
    [string]$Source
    [string]$Destination

    GitFile([string]$Source, [string]$Destination)
    {
        $this.Source = $Source
        $this.Destination = $Destination
    }

    GitFile([pscustomobject]$File)
    {
        if (!$File.Source)
        {
            throw 'Cannot create GitFile object without a Source'
        }
        $this.Source = $File.Source
        $this.Destination = $File.Destination
    }

    GitFile([hashtable]$Change)
    {
        if (!$Change.Source)
        {
            throw 'Cannot create GitFile object without a Source'
        }
        $this.Source = $Change.Source
        $this.Destination = $Change.Destination
    }

    [string] ToString()
    {
        return "{Source: $($this.Source), Destination: $($this.Destination)}"
    }
}

<#
    This class helps us to construct git change objects
#>
class GitChange
{
    [GitDiff]$Staged
    [GitDiff]$Unstaged

    GitChange([string]$Staged, [string]$Unstaged)
    {
        $this.Staged = $Staged
        $this.Unstaged = $Unstaged
    }

    GitChange([pscustomobject]$Change)
    {
        if (!$Change.Staged -and !$Change.Unstaged)
        {
            throw 'Cannot create GitChange object without a Staged or Unstaged change'
        }
        $this.Staged = $Change.Staged
        $this.Unstaged = $Change.Unstaged
    }

    GitChange([hashtable]$Change)
    {
        if (!$Change.Staged -and !$Change.Unstaged)
        {
            throw 'Cannot create GitChange object without a Staged or Unstaged change'
        }
        $this.Staged = $Change.Staged
        $this.Unstaged = $Change.Unstaged
    }

    [string] ToString()
    {
        return "{Staged: $($this.Staged), Unstaged: $($this.Unstaged)}"
    }
}

<#
    This class helps us format git status objects
#>
class GitStatus
{
    [GitDiff]$Staged
    [GitDiff]$Unstaged
    [string]$Source
    [string]$Destination

    GitStatus([string]$Staged, [string]$Unstaged, [string]$Source, [string]$Destination)
    {
        $this.Staged = $Staged
        $this.Unstaged = $Unstaged
        $this.Source = $Source
        $this.Destination = $Destination
    }

    GitStatus([pscustomobject]$Status)
    {
        if (!$Status.Staged -and !$Status.Unstaged)
        {
            throw 'Cannot create GitStatus object without a Staged or Unstaged change'
        }
        if (!$Status.Source)
        {
            throw 'Cannot create GitStatus object without a Source'
        }
        $this.Staged = $Status.Staged
        $this.Unstaged = $Status.Unstaged
        $this.Source = $Status.Source
        $this.Destination = $Status.Destination
    }

    GitStatus([hashtable]$Status)
    {
        if (!$Status.Staged -and !$Status.Unstaged)
        {
            throw 'Cannot create GitStatus object without a Staged or Unstaged change'
        }
        if (!$Status.Source)
        {
            throw 'Cannot create GitStatus object without a Source'
        }
        $this.Staged = $Status.Staged
        $this.Unstaged = $Status.Unstaged
        $this.Source = $Status.Source
        $this.Destination = $Status.Destination
    }
}

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
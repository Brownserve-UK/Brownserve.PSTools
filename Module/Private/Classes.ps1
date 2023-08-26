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
    This class helps us format git status objects
#>
class GitStatus
{
    [GitDiff]$Staged
    [GitDiff]$Unstaged
    [string]$Source
    hidden [string]$Destination

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

<#
    Simple enum for GitHub issue/PR states
#>
enum GitHubIssueState
{
    Open
    Closed
    All
}

## Type validation classes

<#
    Simple class to ensure datetime objects are displayed as short dates in output but retain their date time attribute
#>
class BrownserveShortDate
{
    [datetime]$Date

    BrownserveShortDate([datetime]$Date)
    {
        $this.Date = $Date
    }

    BrownserveShortDate([string]$Date)
    {
        $this.Date = $Date
    }

    [string] ToString()
    {
        return "$(Get-Date $this.Date -Format 'yyyy/MM/dd')"
    }
}

<#
    This class helps us to format version history entries from a changelog
#>
class BrownserveVersionHistory
{
    [semver]$Version
    [BrownserveShortDate]$ReleaseDate
    [string]$URL
    [string[]]$ReleaseNotes
    [bool]$PreRelease = $false

    BrownserveVersionHistory([semver]$Version, [datetime]$ReleaseDate, [string]$URL, [string]$ReleaseNotes)
    {
        $this.Version = $Version
        $this.ReleaseDate = $ReleaseDate
        $this.URL = $URL
        $this.ReleaseNotes = $ReleaseNotes
        if ($this.Version.PreReleaseLabel)
        {
            $this.PreRelease = $true
        }
    }

    BrownserveVersionHistory([pscustomobject]$VersionHistory)
    {
        if (!$VersionHistory.Version)
        {
            throw 'Cannot create BrownserveVersionHistory object without a Version'
        }
        if (!$VersionHistory.ReleaseDate)
        {
            throw 'Cannot create BrownserveVersionHistory object without a ReleaseDate'
        }
        if (!$VersionHistory.URL)
        {
            throw 'Cannot create BrownserveVersionHistory object without a URL'
        }
        if (!$VersionHistory.ReleaseNotes)
        {
            throw 'Cannot create BrownserveVersionHistory object without ReleaseNotes'
        }
        $this.Version = $VersionHistory.Version
        $this.ReleaseDate = $VersionHistory.ReleaseDate
        $this.URL = $VersionHistory.URL
        $this.ReleaseNotes = $VersionHistory.ReleaseNotes
        if ($this.Version.PreReleaseLabel)
        {
            $this.PreRelease = $true
        }
    }

    BrownserveVersionHistory([hashtable]$VersionHistory)
    {
        if (!$VersionHistory.Version)
        {
            throw 'Cannot create BrownserveVersionHistory object without a Version'
        }
        if (!$VersionHistory.ReleaseDate)
        {
            throw 'Cannot create BrownserveVersionHistory object without a ReleaseDate'
        }
        if (!$VersionHistory.URL)
        {
            throw 'Cannot create BrownserveVersionHistory object without a URL'
        }
        if (!$VersionHistory.ReleaseNotes)
        {
            throw 'Cannot create BrownserveVersionHistory object without ReleaseNotes'
        }
        $this.Version = $VersionHistory.Version
        $this.ReleaseDate = $VersionHistory.ReleaseDate
        $this.URL = $VersionHistory.URL
        $this.ReleaseNotes = $VersionHistory.ReleaseNotes
        if ($this.Version.PreReleaseLabel)
        {
            $this.PreRelease = $true
        }
    }

    [string] ToString()
    {
        return "$($this.Version) - $($this.ReleaseDate)"
    }
}

<#
    Class for storing Brownserve Changelog data
#>
class BrownserveChangelog
{
    [BrownserveVersionHistory[]]$VersionHistory
    [int]$NewEntryInsertLine
    [BrownserveVersionHistory]$LatestVersion

    BrownserveChangelog([BrownserveVersionHistory[]]$VersionHistory, [int]$NewEntryInsertLine)
    {
        $this.VersionHistory = $VersionHistory | Sort-Object -Property ReleaseDate -Descending
        $this.NewEntryInsertLine = $NewEntryInsertLine
        $this.LatestVersion = $this.VersionHistory[0]
    }

    BrownserveChangelog([pscustomobject]$Changelog)
    {
        if (!$Changelog.VersionHistory)
        {
            throw 'Cannot create BrownserveChangelog object without VersionHistory'
        }
        if (!$Changelog.NewEntryInsertLine)
        {
            throw 'Cannot create BrownserveChangelog object without NewEntryInsertLine'
        }
        $this.VersionHistory = $Changelog.VersionHistory | Sort-Object -Property ReleaseDate -Descending
        $this.NewEntryInsertLine = $Changelog.NewEntryInsertLine
        $this.LatestVersion = $this.VersionHistory[0]
    }

    BrownserveChangelog([hashtable]$Changelog)
    {
        if (!$Changelog.VersionHistory)
        {
            throw 'Cannot create BrownserveChangelog object without VersionHistory'
        }
        if (!$Changelog.NewEntryInsertLine)
        {
            throw 'Cannot create BrownserveChangelog object without NewEntryInsertLine'
        }
        $this.VersionHistory = $Changelog.VersionHistory | Sort-Object -Property ReleaseDate -Descending
        $this.NewEntryInsertLine = $Changelog.NewEntryInsertLine
        $this.LatestVersion = $this.VersionHistory[0]
    }
}
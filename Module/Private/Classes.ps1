<#
.DESCRIPTION
    Special private classes for the module.
    Previously the module used to have a lot of private classes spread across various files
    this is an attempt to consolidate them into one file.
    It's important that classes remain in one file as when they are in individual files they can be loaded in the wrong
    order which can cause 'type not found' errors.
    It also breaks IDE's as they can't find the type definition.
#>


## Common classes

<#
.SYNOPSIS
    This enum performs some simple validation for line endings.
#>
enum BrownserveLineEnding
{
    LF
    CRLF
    CR
}

<#
.SYNOPSIS
    This class helps us format the content returned by Get-Content.
#>
class BrownserveContent
{
    [string[]]$Content
    hidden [string]$Path
    hidden [BrownserveLineEnding]$LineEnding

    BrownserveContent([string[]]$Content, [string]$Path, [string]$LineEnding)
    {
        $this.Content = $Content
        $this.Path = $Path
        $this.LineEnding = $LineEnding
    }

    BrownserveContent([pscustomobject]$Content)
    {
        if (!$Content.Content)
        {
            throw 'Cannot create BrownserveContent object without Content'
        }
        if (!$Content.Path)
        {
            throw 'Cannot create BrownserveContent object without Path'
        }
        if (!$Content.LineEnding)
        {
            throw 'Cannot create BrownserveContent object without LineEnding'
        }
        $this.Content = $Content.Content
        $this.Path = $Content.Path
        $this.LineEnding = $Content.LineEnding
    }

    BrownserveContent([hashtable]$Content)
    {
        if (!$Content.Content)
        {
            throw 'Cannot create BrownserveContent object without Content'
        }
        if (!$Content.Path)
        {
            throw 'Cannot create BrownserveContent object without Path'
        }
        if (!$Content.LineEnding)
        {
            throw 'Cannot create BrownserveContent object without LineEnding'
        }
        $this.Content = $Content.Content
        $this.Path = $Content.Path
        $this.LineEnding = $Content.LineEnding
    }

    [string] ToString()
    {
        return $this.Content -join $this.NewLine()
    }

    # We can call this method to easily get the line ending for the file
    [string] NewLine()
    {
        switch ($this.LineEnding)
        {
            'LF'
            {
                return "`n"
            }
            'CRLF'
            {
                return "`r`n"
            }
            'CR'
            {
                return "`r"
            }
            default
            {
                throw "Unsupported line ending '$($this.LineEnding)'"
            }
        }
        throw "Unsupported line ending '$($this.LineEnding)'"
    }
}

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
    hidden [string]$ChangelogPath
    hidden [string[]]$Content

    BrownserveChangelog([BrownserveVersionHistory[]]$VersionHistory, [int]$NewEntryInsertLine, [string]$ChangelogPath, [string[]]$Content)
    {
        $this.VersionHistory = $VersionHistory | Sort-Object -Property ReleaseDate -Descending
        $this.NewEntryInsertLine = $NewEntryInsertLine
        $this.LatestVersion = $this.VersionHistory[0]
        $this.ChangelogPath = $ChangelogPath
        $this.Content = $Content
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
        if (!$Changelog.ChangelogPath)
        {
            throw 'Cannot create BrownserveChangelog object without ChangelogPath'
        }
        if (!$Changelog.Content)
        {
            throw 'Cannot create BrownserveChangelog object without Content'
        }
        $this.VersionHistory = $Changelog.VersionHistory | Sort-Object -Property ReleaseDate -Descending
        $this.NewEntryInsertLine = $Changelog.NewEntryInsertLine
        $this.LatestVersion = $this.VersionHistory[0]
        $this.ChangelogPath = $Changelog.ChangelogPath
        $this.Content = $Changelog.Content
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
        if (!$Changelog.ChangelogPath)
        {
            throw 'Cannot create BrownserveChangelog object without ChangelogPath'
        }
        if (!$Changelog.Content)
        {
            throw 'Cannot create BrownserveChangelog object without Content'
        }
        $this.VersionHistory = $Changelog.VersionHistory | Sort-Object -Property ReleaseDate -Descending
        $this.NewEntryInsertLine = $Changelog.NewEntryInsertLine
        $this.LatestVersion = $this.VersionHistory[0]
        $this.ChangelogPath = $Changelog.ChangelogPath
        $this.Content = $Changelog.Content
    }
}

## IDE related classes

<#
    This class helps us format editorconfig properties
#>
class EditorConfigProperty
{
    [string]$Name
    $Value

    EditorConfigProperty([string]$Name, $Value)
    {
        $this.Name = $Name
        $this.Value = $Value
        $this.ValidityCheck()
    }

    EditorConfigProperty([hashtable]$Property)
    {
        $this.Value = $Property.Value
        $this.Name = $Property.Name
        $this.ValidityCheck()
    }

    EditorConfigProperty([System.Collections.DictionaryEntry]$Property)
    {
        $this.Value = $Property.Value
        $this.Name = $Property.Name
        $this.ValidityCheck()
    }

    [string] ToString()
    {
        return ("$($this.Name) = $($this.Value)").ToLower()
    }

    hidden ValidityCheck()
    {
        # Ensure that the property name is valid as per the editorconfig spec (https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties)
        $ValidPropertyNames = @(
            'indent_style',
            'indent_size',
            'tab_width',
            'end_of_line',
            'charset',
            'trim_trailing_whitespace',
            'insert_final_newline',
            'max_line_length'
        )
        if ($this.Name -notin $ValidPropertyNames)
        {
            throw "Invalid editorconfig property name: '$($this.Name)'"
        }

        # Ensure that the property value is valid as per the editorconfig spec
        switch ($this.Name)
        {
            'indent_style'
            {
                $ValidValues = @('tab', 'space')
                if ($this.Value -notin $ValidValues)
                {
                    throw "Invalid indent_style value: '$($this.Value)'"
                }
            }
            'indent_size'
            {
                (($this.Value -isnot [int]) -or ($this.Value -isnot [Int64]))
                {
                    if ($this.Value -ne 'tab')
                    {
                        throw "Invalid indent_size value: '$($this.Value)'"
                    }
                }
            }
            'tab_width'
            {
                (($this.Value -isnot [int]) -or ($this.Value -isnot [Int64]))
                {
                    throw "Invalid tab_width value: '$($this.Value)'"
                }
            }
            'end_of_line'
            {
                $ValidValues = @('lf', 'cr', 'crlf')
                if ($this.Value -notin $ValidValues)
                {
                    throw "Invalid end_of_line value: '$($this.Value)'"
                }
            }
            'charset'
            {
                $ValidValues = @('latin1', 'utf-8', 'utf-8-bom', 'utf-16be', 'utf-16le')
                if ($this.Value -notin $ValidValues)
                {
                    throw "Invalid charset value: '$($this.Value)'"
                }
            }
            'trim_trailing_whitespace'
            {
                if ($this.Value -isnot [bool])
                {
                    throw "Invalid trim_trailing_whitespace value: '$($this.Value)'"
                }
            }
            'insert_final_newline'
            {
                if ($this.Value -isnot [bool])
                {
                    throw "Invalid insert_final_newline value: '$($this.Value)'"
                }
            }
            'max_line_length'
            {
                if (($this.Value -isnot [int]) -or ($this.Value -isnot [Int64]))
                {
                    if ($this.Value -ne 'off')
                    {
                        throw "Invalid max_line_length value: '$($this.Value)'"
                    }
                }
            }
        }
    }
}

<#
    This class helps us format editorconfig sections
#>
class EditorConfigSection
{
    [string]$FilePath
    [EditorConfigProperty[]]$Properties
    [string[]]$Comment

    EditorConfigSection([string]$FilePath, [EditorConfigProperty[]]$Properties)
    {
        $this.FilePath = $FilePath
        $this.Properties = $Properties
    }

    EditorConfigSection([string]$FilePath, [EditorConfigProperty[]]$Properties, [string[]]$Comment)
    {
        $this.FilePath = $FilePath
        $this.Properties = $Properties
        $this.Comment = $Comment
    }

    EditorConfigSection([hashtable]$Section)
    {
        if (!$Section.FilePath)
        {
            throw 'Cannot create EditorConfigSection object without FilePath'
        }
        if (!$Section.Properties)
        {
            throw 'Cannot create EditorConfigSection object without Properties'
        }
        if ($Section.Comment)
        {
            $this.Comment = $Section.Comment
        }
        $this.FilePath = $Section.FilePath
        if ($Section.Properties -is [hashtable])
        {
            $this.ExpandProperties($Section.Properties)
        }
        else
        {
            $this.Properties = $Section.Properties
        }
    }

    # It's much more convenient to be able to pass in a hash of all the properties
    # but we need to expand them all first
    hidden ExpandProperties([hashtable]$Properties)
    {
        $ExpandedProps = @()
        $Properties.GetEnumerator() | ForEach-Object {
            $ExpandedProps += [EditorConfigProperty]$_
        }
        $this.Properties = $ExpandedProps
    }

    # Override the default ToString method, let's output exactly what we want!
    [string] ToString()
    {
        $Return = ''
        if ($this.Comment)
        {
            $this.Comment | ForEach-Object {
                if ($_.StartsWith('#'))
                {
                    $Return += "$_`n"
                }
                else
                {
                    $Return += "# $_`n"
                }
            }
        }
        if ($this.FilePath -notmatch '^\[.*\]$')
        {
            $Return += "[$($this.FilePath)]`n"
        }
        else
        {
            $Return += "$($this.FilePath)`n"
        }
        $this.Properties | ForEach-Object {
            $Return += "$($_)`n"
        }
        return $Return
    }
}

## Markdown related classes

enum MarkdownEmphasisAsHeaderConversion
{
    List
    Header
}

## PowerShell related classes


enum BrownservePowerShellModuleType
{
    Standalone
    Tool
}

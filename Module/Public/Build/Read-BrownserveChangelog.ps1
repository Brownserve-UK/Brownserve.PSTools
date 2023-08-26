<#
.SYNOPSIS
    Reads in a changelog file and returns the contents as a custom object.
.DESCRIPTION
    This cmdlet will read in a changelog file and return the contents as a custom object.
    The changelog file must be in the standard Brownserve format.
#>
function Read-BrownserveChangelog
{
    [CmdletBinding()]
    param
    (
        # The path to the changelog file
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $ChangelogPath,

        # The regex to use for version matching.
        # It should always contain a capture group named "version" as this is what the regex matcher will use to extract the version number
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $VersionPattern = '^#*\s\[v(?<version>[0-9]+\.[0-9]+\.[0-9]+)\]\((?:.*)\)\s\([0-9]+\-[0-9]+\-[0-9]+\)$',

        # The regex pattern for matching the release URL.
        # It should always contain a capture group named "url" and this what the regex searched will use to extract your url
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $ReleaseURLPattern = '(?<url>[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(?:\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?)',

        # The regex pattern for matching the date of the last release.
        # It should always contain a capture group named "date" and this what the regex searched will use to extract your date
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $ReleaseDatePattern = '\((?<date>[\d|-]*)\)'
    )
    begin
    {
        $Return = @()
    }
    process
    {
        # Import the changelog, we don't use the -Raw switch as we want to read the file line by line
        try
        {
            $Changelog = Get-Content $ChangelogPath
        }
        catch
        {
            throw "Failed to get changelog content.$($_.Exception.Message)"
        }

        # We'll read through the changelog line-by-line and keep a track of various important lines
        $LineCount = 0

        <#
            As we go through each line we'll begin building a version history
        #>
        $VersionHistory = @()

        <#
            To get the release notes for a version we need to know the line of that contains the previously released
            version as well as the version we are currently checking, this is so we can extract the text from between
            these two versions which should be the release notes
        #>
        $PreviousVersion = $null
        $PreviousReleaseDate = $null
        $PreviousURL = $null
        $ReleaseNotesStartOn = $null
        $ReleaseNotesEndOn = $null

        # Go through each line until we find what we need
        $Changelog | ForEach-Object {
            $Line = $_.Trim()
            # See if the line matches a version
            $VersionMatch = [regex]::Match($Line, $VersionPattern)
            if ($VersionMatch.Success)
            {
                Write-Debug "Current line is: $LineCount"
                Write-Debug "Line contents: $Line"
                # Congratulations this line matches a version number. 🎉 we'll store it for use later
                $ThisVersion = [semver]$VersionMatch.Groups['version'].Value
                # This line should also contain a date of the release, we'll want that too
                $ReleaseDateMatch = [regex]::Match($Line, $ReleaseDatePattern)
                if ($ReleaseDateMatch.Success)
                {
                    $ThisReleaseDate = $ReleaseDateMatch.Groups['date'].Value
                }
                $ReleaseURLMatch = [regex]::Match($Line, $ReleaseURLPattern)
                if ($ReleaseURLMatch.Success)
                {
                    $ThisURL = $ReleaseURLMatch.Groups['url'].Value
                }
                if (-not $NewChangelogLine)
                {
                    <#
                        We need to know where to insert a new changelog entry.
                        As our changelog goes in descending order (newest releases at the top) the line to insert a new
                        entry is the line directly before the first version string we match against.
                    #>
                    $NewChangelogLine = $LineCount - 1
                }
                <#
                    TODO: explain
                #>
                if (-not $PreviousVersion)
                {
                    $PreviousVersion = $ThisVersion
                    $PreviousReleaseDate = $ThisReleaseDate
                    $PreviousURL = $ThisURL
                    # The release notes for this version will start on the _next_ line after the version number
                    $ReleaseNotesStartOn = $LineCount + 1
                }
                else
                {
                    # The release notes will end on the line _before_ the previous version number
                    $ReleaseNotesEndOn = $LineCount - 1
                    $ThisReleaseNotes = $Changelog[$ReleaseNotesStartOn..$ReleaseNotesEndOn]

                    # Try to trim off any empty lines at the start and end of the release note text
                    $LastLine = $ThisReleaseNotes.Count
                    while (!$ThisReleaseNotes[-1])
                    {
                        $LastLine = $LastLine - 1
                        $ThisReleaseNotes = $ThisReleaseNotes[0..$LastLine]
                    }
                    $FirstLine = 0
                    while (!$ThisReleaseNotes[0])
                    {
                        $LastLine = $ThisReleaseNotes.Count
                        $FirstLine ++
                        $ThisReleaseNotes = $ThisReleaseNotes[$FirstLine..$LastLine]
                    }

                    <#
                        Create an object of the data we've gathered
                    #>
                    $VersionHistory += [BrownserveVersionHistory]@{
                        Version      = $PreviousVersion
                        ReleaseDate  = $PreviousReleaseDate
                        URL          = $PreviousURL
                        ReleaseNotes = $ThisReleaseNotes
                    }


                    # TODO: explain
                    $PreviousVersion = $ThisVersion
                    $PreviousReleaseDate = $ThisReleaseDate
                    $PreviousURL = $ThisURL
                    $ReleaseNotesStartOn = $LineCount + 1
                }
            }
            # Finally increase the line count for the next loop
            $LineCount++
        }
        <#
            To get the release notes from the last entry in the list we need to
            TODO: explain
        #>
        $LastReleaseNotes = $Changelog[$ReleaseNotesStartOn..$Changelog.Count]
        # Try to trim off any empty lines at the start and end of the release note text
        $LastLine = $LastReleaseNotes.Count
        while (!$LastReleaseNotes[-1])
        {
            $LastLine = $LastLine - 1
            $LastReleaseNotes = $LastReleaseNotes[0..$LastLine]
        }
        $FirstLine = 0
        while (!$LastReleaseNotes[0])
        {
            $LastLine = $LastReleaseNotes.Count
            $FirstLine ++
            $LastReleaseNotes = $LastReleaseNotes[$FirstLine..$LastLine]
        }
        $VersionHistory += [BrownserveVersionHistory]@{
            Version      = $PreviousVersion
            ReleaseDate  = $PreviousReleaseDate
            URL          = $PreviousURL
            ReleaseNotes = $LastReleaseNotes
        }

        # TODO: Do we want to create a "LatestVersion object?"
        $Return += [pscustomobject]@{
            ChangeLogPath  = $ChangelogPath # The path to the changelog - useful when piping into other cmdlets
            VersionHistory = $VersionHistory | Sort-Object -Property Version -Descending # The version history of the changelog
            LatestVersion  = $VersionHistory[0].Version # The latest version according to the changelog
            ReleasedOn     = $VersionHistory[0].ReleaseDate # The date of the last release
            ReleaseNotes   = $VersionHistory[0].ReleaseNotes -join [System.Environment]::NewLine # The release notes for the latest version only
            NextEntryLine  = $NewChangelogLine # This will be the line that we can start inserting new entries into
        }
    }
    end
    {
        if ($Return.Count -gt 0)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}
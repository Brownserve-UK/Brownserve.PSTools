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

        # We'll store all the lines after the headers in this array so we can get the entire changelog text if we want it
        $ChangelogText = @()

        # We'll read through the changelog line-by-line and keep a track of various important lines
        $LineCount = 0

        <#
            As we go through each line we'll begin building a version history
        #>
        $VersionHistory = @()

        <#
            To get the changes that feature in the latest entry (i.e. release notes) we need to know both the current and
            previous released versions.
            We can then find the text block between these lines which should be our release notes.
        #>
        $CurrentVersion = $null
        $PreviousVersion = $null
        $ReleaseNotesStartOn = $null
        $ReleaseNotesEndOn = $null

        # We'll also look for the line that we can insert a new entry into (if we want)
        $NewChangelogLine = $null

        # We'll also look for the date of the last release
        $LastReleaseDate = $null

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
                <#
                    If we don't already have the current version then this must be it as our changelog is descending order
                    Set the $CurrentVersionVariable, we'll also be able to tell where the current release notes start as
                    they will be on the next line _after_ the version line.
                    Similarly the line for inserting a new entry will be the line _before_ the current versions line
                #>
                if (-not $CurrentVersion)
                {
                    $CurrentVersion = $ThisVersion
                    # The current release notes will start on the _next_ line after the version number
                    $ReleaseNotesStartOn = $LineCount + 1
                    # If we want to insert any new changelog entries then we'll need to known where we can do that
                    # It will be the line _before_ our line with the version number on
                    $NewChangelogLine = $LineCount - 1
                    Write-Verbose "Current version determined to be $CurrentVersion"
                    # Now we've got our current version we can also extract the date of the last release
                    $LastReleaseDate = $ThisReleaseDate
                    Write-Verbose "Last release date determined to be $LastReleaseDate"
                }
                else
                {
                    <#
                        We should only end up here once $CurrentVersion has been set on a previous line read.
                        This should ensure we can never accidentally read the CurrentVersion as the PreviousVersion
                    #>
                    if (-not $PreviousVersion)
                    {
                        # We've found a potential match!
                        $PreviousVersion = $ThisVersion
                        # The release notes will end on the line _before_ the previous version number
                        $ReleaseNotesEndOn = $LineCount - 1
                        <#
                            Just in case we've somehow ended up with PreviousVersion and CurrentVersion being the same
                            (i.e. we've read the same line twice!)
                            Then we reset the variables and carry on
                        #>
                        if ($PreviousVersion -eq $CurrentVersion)
                        {
                            $PreviousVersion = $null
                            $ReleaseNotesEndOn = $null
                        }
                    }
                }
                <#
                    Once the $CurrentVersion variable has been set we know that we've gone past the header section and
                    whitespace at the top of the changelog and we should be good to start storing every line of text to
                    return the changelog sans the header.
                #>
                if ($CurrentVersion)
                {
                    $ChangelogText += $Line
                }

                <#
                    Create an object of the data we've gathered
                #>
                $VersionHistory += [pscustomobject]@{
                    Version     = $ThisVersion
                    ReleaseDate = $ThisReleaseDate
                    URL         = $ThisURL
                }
            }
            # Finally increase the line count for the next loop
            $LineCount++
        }

        # If we haven't got our release notes ending line _and_ a previous version it likely means that we don't have one! (i.e. we are still on the first release!)
        # So just read until the end of the file
        if ((-not $ReleaseNotesEndOn) -and (-not $PreviousVersion))
        {
            Write-Verbose "It looks like there is only one release.`nRelease notes will be read from line $ReleaseNotesStartOn until the end of the file"
            $ReleaseNotesEndOn = $Changelog.Length
        }
        else
        {
            Write-Verbose "Previous version was: $PreviousVersion, the current versions release notes end on line $ReleaseNotesEndOn"
        }
        # Extract the lines that equate to our current release notes
        try
        {
            $ReleaseNotes = $Changelog[$ReleaseNotesStartOn..$ReleaseNotesEndOn]

            # Try to trim off any empty lines at the start and end of the release note text
            $LastLine = $ReleaseNotes.Count
            while (!$ReleaseNotes[-1])
            {
                $LastLine = $LastLine -1
                $ReleaseNotes = $ReleaseNotes[0..$LastLine]
            }
            $FirstLine = 0
            while (!$ReleaseNotes[0])
            {
                $LastLine = $ReleaseNotes.Count
                $FirstLine ++
                $ReleaseNotes = $ReleaseNotes[$FirstLine..$LastLine]
            }
        }
        catch
        {
            # Ignore errors, we'll throw below
        }

        # If we haven't found a version or the release notes, raise an error
        if (-not $CurrentVersion)
        {
            throw "Failed to find version in changelog file: $ChangelogPath"
        }
        if (!$ReleaseNotes)
        {
            throw 'Unable to work out current release notes.'
        }

        # TODO: Do we want to create a "LatestVersion object?"
        $Return += [pscustomobject]@{
            ChangeLogPath  = $ChangelogPath # The path to the changelog - useful when piping into other cmdlets
            VersionHistory = $VersionHistory | Sort-Object -Property Version -Descending # The version history of the changelog
            LatestVersion  = $CurrentVersion # The latest version according to the changelog
            ReleasedOn     = $LastReleaseDate # The date of the last release
            ReleaseNotes   = $ReleaseNotes -join [System.Environment]::NewLine # The release notes for the latest version only
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
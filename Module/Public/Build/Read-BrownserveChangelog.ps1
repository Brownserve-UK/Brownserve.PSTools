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

        # The regex pattern for matching the repo URL.
        # It should always contain a capture group named "url" and this what the regex searched will use to extract your url
        [Parameter(
            Mandatory = $false,
            DontShow
        )]
        [string]
        $RepoURLPattern = '(?<url>http(?:.*))\/tree',

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
            # Return the URL of the repo if we can find it
            if (-not $RepoUrl)
            {
                $RepoUrlMatch = [regex]::Match($Line, $RepoUrlPattern)
                if ($RepoUrlMatch.Success)
                {
                    $RepoUrl = $RepoUrlMatch.Groups['url'].Value
                    Write-Verbose "Repo URL determined to be $RepoURL"
                }
            }
            # If we don't already have our current version then see if this line contains it...
            if (-not $CurrentVersion)
            {
                $RegexMatch = [regex]::Match($Line, $VersionPattern)
                if ($RegexMatch.Success)
                {
                    # This line matches our version regex!
                    # This has to be the first line we've come across that matches it so it must be the current version.
                    # Extract the version number from our capture group
                    $CurrentVersion = [version] $RegexMatch.Groups['version'].Value
                    # The current release notes will start on the _next_ line after the version number 
                    $ReleaseNotesStartOn = $LineCount + 1
                    # If we want to insert any new changelog entries then we'll need to known where we can do that
                    # It will be the line _before_ our line with the version number on
                    $NewChangelogLine = $LineCount - 1
                    Write-Verbose "Current version determined to be $CurrentVersion"
                    # Now we've got our current version we can also extract the date of the last release
                    $LastReleaseDateMatch = [regex]::Match($Line, $ReleaseDatePattern)
                    if ($LastReleaseDateMatch.Success)
                    {
                        $LastReleaseDate = Get-Date $LastReleaseDateMatch.Groups['date'].Value -ErrorAction 'Stop'
                        Write-Verbose "Last release date determined to be $LastReleaseDate"
                    }
                }
            }
            # If we've found our current version number then from here on out the rest of the document will be our changelog, start capturing it!
            if ($CurrentVersion)
            {
                $ChangelogText += $Line
            }
            # If we don't already have the previous version number see if this line contains it...
            if (-not $PreviousVersion)
            {
                $RegexMatch = [regex]::Match($Line, $VersionPattern)
                if ($RegexMatch.Success)
                {
                    # We've found a potential match!
                    $PreviousVersion = [version] $RegexMatch.Groups['version'].Value
                    # The release notes will end on the line _before_ the previous version number
                    $ReleaseNotesEndOn = $LineCount - 1
                    # If we've hit the current version then we haven't gone far enough back!
                    # Clear our variables and continue looking
                    if ($PreviousVersion -eq $CurrentVersion)
                    {
                        $PreviousVersion = $null
                        $ReleaseNotesEndOn = $null
                    }
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
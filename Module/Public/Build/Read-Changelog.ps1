function Read-Changelog
{
    [CmdletBinding()]
    param(
        # The path of the changelog file to read from, wildcards are permitted.
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
            Position = 1
        )]
        [string]
        $VersionPattern = '^#*\s\[v(?<version>[0-9]+\.[0-9]+\.[0-9]+)\]\((?:.*)\)\s\([0-9]+\-[0-9]+\-[0-9]+\)$',

        # The regex pattern for matching the repo URL.
        # It should always contain a capture group named "url" and this what the regex searched will use to extract your url
        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [string]
        $RepoURLPattern = '(?<url>http(?:.*))\/tree'
    )

    # Import the changelog
    try
    {
        $Changelog = Get-Content $ChangelogPath
    }
    catch
    {
        throw "Failed to get changelog content.$($_.Exception.Message)"
    }
    
    # We'll store all the lines after the headers in this array so we can get the ChangelogText if we want it
    $ChangelogText = @()

    # We'll look for our current version and previous version so we can get the text in-between which _should_ be our new release notes
    $CurrentVersion = $null
    $PreviousVersion = $null

    # We'll read through each line of this text file so we can work out where our current release notes are
    $LineCount = 0
    $ReleaseNotesStartOn = $null
    $ReleaseNotesEndOn = $null

    # We'll also look for the line that we can insert a new entry into (if we want)
    $NewChangelogLine = $null
    
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
        throw "Unable to work out current release notes."
    }

    return [pscustomobject]@{
        ChangeLogPath  = $ChangelogPath # The path to the changelog - useful when piping into other cmdlets
        RepoURL        = $RepoURL # The URL of the repo, useful in other cmdlets
        Content        = $Changelog # Return the whole changelog in all it's gory detail
        VersionHistory = $ChangelogText # The version history of the changelog
        CurrentVersion = $CurrentVersion # The latest version according to the changelog
        ReleaseNotes   = $ReleaseNotes -join [System.Environment]::NewLine # The release notes for the latest version only
        InsertLine     = $NewChangelogLine # This will be the line that we can start inserting new entries into
    }
}
function New-ChangelogBlock
{
    [CmdletBinding()]
    param
    (
        # The version number
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true
        )]
        [version]
        $Version,

        # The URL to the repo
        [Parameter(
            Mandatory = $true,
            Position = 2,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $RepoURL,

        # The new features that have been added in this version
        [Parameter(
            Mandatory = $true,
            Position = 3,
            ValueFromPipelineByPropertyName = $true
        )]
        [array]
        $Features,

        # Any bugfixes that have been introduced in this version
        [Parameter(
            Mandatory = $false,
            Position = 4,
            ValueFromPipelineByPropertyName = $true
        )]
        [array]
        $Bugfixes,

        # Any known issues
        [Parameter(
            Mandatory = $false,
            Position = 5,
            ValueFromPipelineByPropertyName = $true
        )]
        [array]
        $KnownIssues
    )
    # Make sure our repo URL doesn't have a trailing slash
    $RepoURL = $RepoURL -replace '\/$', ''

    # Start by creating each header
    $VersionHeader = "### [v$($Version.ToString())]($($RepoURL)/tree/v$($Version.ToString())) ($(Get-Date -Format yyyy-MM-dd))`n"
    $FeaturesBlock = "**Features**`n"
    foreach ($Feature in $Features)
    {
        $FeaturesBlock = $FeaturesBlock + "- $Feature`n"
    }
    $BugfixBlock = "**Bugfixes**`n"
    # If we've got some bug fixes, list them out otherwise simply add and N/A
    if ($Bugfixes)
    {
        foreach ($Bugfix in $Bugfixes)
        {
            $BugfixBlock = $BugfixBlock + "- $Bugfix`n"
        }
    }
    else
    {
        $BugfixBlock = $BugfixBlock + "N/A`n"
    }
    # Same for known issues
    $KnownIssueBlock = "**Known Issues**`n"
    if ($KnownIssues)
    {
        foreach ($KnownIssue in $KnownIssues)
        {
            
            $KnownIssueBlock = $KnownIssueBlock + "- $KnownIssue"
            # Avoid putting a newline on our last entry to keep formatting consistent
            if ($KnownIssue -ne $KnownIssues[-1])
            { 
                $KnownIssueBlock = $KnownIssueBlock + "`n"
            }
        }
    }
    else
    {
        $KnownIssueBlock = $KnownIssueBlock + "N/A"
    }
    # Now concatenate all the bits together with some spacers and return it
    $FinalBlock = $VersionHeader + "`n" + $FeaturesBlock + "`n" + $BugfixBlock + "`n" + $KnownIssueBlock

    Return $FinalBlock
}
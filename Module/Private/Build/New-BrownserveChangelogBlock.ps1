<#
.SYNOPSIS
    Formats a changelog block for use in a Brownserve changelog.
.DESCRIPTION
    Very simple that will create a properly formatted changelog block for use in a Brownserve changelog.
#>
function New-BrownserveChangelogBlock
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
        [semver]
        $Version,

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
        $KnownIssues,

        # The repository owner
        [Parameter(
            Mandatory = $true,
            Position = 6,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $RepositoryOwner,

        # The repository name
        [Parameter(
            Mandatory = $true,
            Position = 7,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $RepositoryName,

        # The repository host
        [Parameter(
            Mandatory = $false,
            Position = 8,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $RepositoryHost = 'github.com'
    )
    begin
    {
    }
    process
    {
        # Make sure our repo URL doesn't have a trailing slash
        $RepoURL = $RepoURL -replace '\/$', ''

        # Start by creating each header
        $VersionHeader = "### [v$($Version.ToString())](https://$RepositoryHost/$RepositoryOwner/$RepositoryName/tree/v$($Version.ToString())) ($(Get-Date -Format yyyy-MM-dd))`n`n"
        $FeaturesBlock = "**Features**  `nThese are the changes that have been made since the last release:`n`n"
        foreach ($Feature in $Features)
        {
            $FeaturesBlock = $FeaturesBlock + "- $Feature`n"
        }
        $BugfixBlock = "**Bugfixes**  `nThe following bugs have been closed since the last release:`n`n"
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
            $BugfixBlock = $BugfixBlock + "*N/A*`n"
        }
        # Same for known issues
        $KnownIssueBlock = "**Known Issues**  `nThe following bugs have been raised since the last release and remain unresolved:`n`n"
        if ($KnownIssues)
        {
            foreach ($KnownIssue in $KnownIssues)
            {
                $KnownIssueBlock = $KnownIssueBlock + "- $KnownIssue`n"
            }
        }
        else
        {
            $KnownIssueBlock = $KnownIssueBlock + "*N/A*`n"
        }
        $KnownIssueBlock += "`nFor a full list of current known issues see the project's [issues page](https://$RepositoryHost/$($RepositoryOwner)/$($RepositoryName)/issues)."
        # Now concatenate all the bits together with some spacers and return it
        $FinalBlock = $VersionHeader + "`n" + $FeaturesBlock + "`n" + $BugfixBlock + "`n" + $KnownIssueBlock
    }
    end
    {
        Return $FinalBlock
    }
}

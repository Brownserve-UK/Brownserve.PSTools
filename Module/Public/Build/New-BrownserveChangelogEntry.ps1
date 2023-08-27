<#
.SYNOPSIS
    Creates a new changelog entry for a given version in the standard Brownserve format.
.DESCRIPTION
    This cmdlet will generate a new changelog entry in the standard Brownserve format.
    Providing the -Auto parameter will cause the cmdlet to attempt to automatically populate the changelog entry with features, bugfixes and known issues
    based on the GitHub pull requests and issues that have been open/closed since the last release.
#>
function New-BrownserveChangelogEntry
{
    [CmdletBinding()]
    param
    (
        # The path to the changelog file
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $ChangelogPath = $PWD,

        # The Changelog file
        [Parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $ChangelogFile = 'CHANGELOG.md',

        # The version number to use for the new entry
        [Parameter(
            Mandatory = $true,
            Position = 2,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.SemanticVersion]
        $Version,

        # The owner of the repo that the changelog belongs to
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RepositoryOwner,

        # The name of the repo that the changelog belongs to
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RepositoryName,

        # The GitHub token to use for API calls
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $GitHubToken,

        # An optional list of features to add to the changelog (these will be added alongside the auto-generated features)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Features,

        # An optional list of bugfixes to add to the changelog (these will be added alongside the auto-generated bugfixes)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Bugfixes,

        # An optional list of known issues to add to the changelog (these will be added alongside the auto-generated known issues)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $KnownIssues,

        # An optional list of labels to use to filter bug fixes/known issues
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $IssueLabelsToInclude = @('bug', 'documentation'),

        # An optional list of labels to use to filter bug fixes/known issues
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $IssueLabelsToExclude = @('feature request', 'enhancement'),

        # An optional flag to indicate that the cmdlet should attempt to automatically populate the changelog entry with features, bugfixes and known issues
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [switch]
        $Auto,

        # Special hidden parameter to allow the cmdlet to be called from the pipeline using input already collected from Read-BrownserveChangelog
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            DontShow = $true
        )]
        [BrownserveChangeLog]
        $Changelog
    )
    begin
    {
        if ($Auto)
        {
            if (!$GitHubToken)
            {
                throw 'You must provide a GitHub token when using the -Auto parameter'
            }
        }
    }
    process
    {
        $Return = $null
        $PullRequestDetails = @()
        if (!$Changelog)
        {
            try
            {
                $ChangelogFullPath = Join-Path -Path $ChangelogPath -ChildPath $ChangelogFile
                $Changelog = Read-BrownserveChangelog -Path $ChangelogFullPath
            }
            catch
            {
                throw "Failed to read changelog file '$ChangelogFullPath'. `n$($_.Exception.Message)"
            }
        }

        if ($Version -in $Changelog.VersionHistory.Version)
        {
            throw "Version '$Version' already exists in the changelog"
        }

        $LastReleasedVersion = $Changelog.LatestVersion

        if ($Auto)
        {
            <#
            We'll get a list of all the merges since the last release.
            We use these to form the basis of the "features" section of the changelog entry.
        #>
            try
            {
                $MergesSinceLastRelease = Get-GitMerges `
                    -RepositoryPath $ChangelogPath `
                    -ReferenceBranch "v$($LastReleasedVersion.Version)" `
                    -ErrorAction 'Stop'
                <#
                We raise an error if there are no merges since the last release.
                This is because the "features" section should contain a list of all changes since the last release.
                Even if this only contains bugfixes, we still want to list them here.
            #>
                if (!$MergesSinceLastRelease)
                {
                    throw 'No merges found since last release'
                }
            }
            catch
            {
                throw "Failed to get git merges since last release. `n$($_.Exception.Message)"
            }

            # Now we'll reconcile the merge commit hashes with the pull requests to get the details we need for the changelog entry
            try
            {
                $PullRequests = Get-GitHubPullRequests `
                    -RepositoryOwner $RepositoryOwner `
                    -RepositoryName $RepositoryName `
                    -GitHubToken $GitHubToken `
                    -State 'closed' `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to get GitHub pull requests. `n$($_.Exception.Message)"
            }
            $MergesSinceLastRelease | ForEach-Object {
                $MergeCommit = $_
                $PullRequest = $PullRequests | Where-Object { $_.merge_commit_sha -eq $MergeCommit }
                if ($PullRequest)
                {
                    $PullRequestDetails += $PullRequest
                }
                else
                {
                    throw "Failed to find pull request for merge commit '$MergeCommit'"
                }
            }

            # Now we'll get a list of all the issues that were closed/opened since the last release
            try
            {
                $IssuesSinceLastRelease = Get-GitHubIssues `
                    -RepositoryOwner $RepositoryOwner `
                    -RepositoryName $RepositoryName `
                    -GitHubToken $GitHubToken `
                    -State 'all' `
                    -ErrorAction 'Stop' |
                    Where-Object { [datetime]$_.updated_at -gt $LastReleasedVersion.ReleaseDate.Date }
                # We don't raise an error if there are no issues since the last release.
            }
            catch
            {
                throw "Failed to get GitHub issues. `n$($_.Exception.Message)"
            }

            if ($IssueLabelsToInclude)
            {
                $IssuesSinceLastRelease = $IssuesSinceLastRelease |
                    Where-Object { $_.labels.name -in $IssueLabelsToInclude }
            }

            if ($IssueLabelsToExclude)
            {
                $IssuesSinceLastRelease = $IssuesSinceLastRelease |
                    Where-Object { $_.labels.name -notin $IssueLabelsToExclude }
            }

            # Work out which issues have been closed since the last release
            $ClosedIssues = $IssuesSinceLastRelease |
                Where-Object { $_.state -eq 'closed' } |
                    Where-Object { [datetime]$_.closed_at -gt [datetime]$LastReleasedVersion.ReleaseDate.Date }

            $ClosedIssues | ForEach-Object {
                $Bugfixes += "[#$($_.number)]($($_.html_url)) - $($_.title)"
            }

            # Work out which issues have been opened since the last release
            $NewIssues = $IssuesSinceLastRelease |
                Where-Object { $_.state -eq 'open' } |
                    Where-Object { [datetime]$_.created_at -gt [datetime]$LastReleasedVersion.ReleaseDate.Date }

            $NewIssues | ForEach-Object {
                $KnownIssues += "[#$($_.number)]($($_.html_url)) - $($_.title)"
            }

            # Create a "feature" entry for each pull request
            $PullRequestDetails | ForEach-Object {
                $Features += "$($_.title) in [#$($_.number)]($($_.html_url)) by [@$($_.user.login)]($($_.user.html_url))"
            }
        }
        else
        {
            if (!$Features)
            {
                throw 'You must provide a list of features when not using the -Auto parameter'
            }
        }

        $ChangelogBlockParams = @{
            Version         = $Version
            RepositoryOwner = $RepositoryOwner
            RepositoryName  = $RepositoryName
            Features        = $Features
        }
        if ($KnownIssues)
        {
            $ChangelogBlockParams.Add('KnownIssues', $KnownIssues)
        }
        if ($Bugfixes)
        {
            $ChangelogBlockParams.Add('Bugfixes', $Bugfixes)
        }

        try
        {
            $Return = New-BrownserveChangelogBlock @ChangelogBlockParams -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create changelog block.`n$($_.Exception.Message)"
        }
    }
    end
    {
        return $Return
    }
}

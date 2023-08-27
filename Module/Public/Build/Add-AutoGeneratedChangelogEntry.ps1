<#
.SYNOPSIS
    Adds a new entry to the changelog file.
.DESCRIPTION
    This cmdlet will generate a new changelog entry by collecting all merged pull requests, new and closed issues since
    the last release. It will then add the new entry to the changelog file.
    The changelog file must be in the standard Brownserve format.
#>
function Add-AutoGeneratedChangelogEntry
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
        $ChangelogPath = $PWD,

        # The Changelog file
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $ChangelogFile = 'CHANGELOG.md',

        # The version number to use for the new entry
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.SemanticVersion]
        $Version,

        # The owner of the repo that the changelog belongs to
        [Parameter(
            Mandatory = $true,
            Position = 2,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RepositoryOwner,

        # The name of the repo that the changelog belongs to
        [Parameter(
            Mandatory = $true,
            Position = 3,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $RepositoryName,

        # The GitHub token to use for API calls
        [Parameter(
            Mandatory = $true,
            Position = 4,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $GitHubToken,

        # An optional list of features to add to the changelog (these will be added alongside the auto-generated features)
        [Parameter(
            Mandatory = $false,
            Position = 5,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Features,

        # An optional list of bugfixes to add to the changelog (these will be added alongside the auto-generated bugfixes)
        [Parameter(
            Mandatory = $false,
            Position = 6,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $Bugfixes,

        # An optional list of known issues to add to the changelog (these will be added alongside the auto-generated known issues)
        [Parameter(
            Mandatory = $false,
            Position = 7,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $KnownIssues,

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

        try
        {
            $MergesSinceLastRelease = Get-GitMerges `
                -RepositoryPath $ChangelogPath `
                -ReferenceBranch "v$($LastReleasedVersion.Version)" `
                -ErrorAction 'Stop'
            if (!$MergesSinceLastRelease)
            {
                throw 'No merges found since last release'
            }
        }
        catch
        {
            throw "Failed to get git merges since last release. `n$($_.Exception.Message)"
        }

        # Now we'll grab a list of all the PR's that have been merged since the last release
        # to do this we first need to get the PR numbers from the merge commits

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
            $PullRequest = $PullRequests | Where-Object {$_.merge_commit_sha -eq $MergeCommit}
            if ($PullRequest)
            {
                $PullRequestDetails += $PullRequest
            }
            else
            {
                throw "Failed to find pull request for merge commit '$MergeCommit'"
            }
        }

        $PullRequestDetails | ForEach-Object {
            $Features += "$($_.title) in [#$($_.number)]($($_.html_url)) by [@$($_.user.login)]($($_.user.html_url))"
        }

        $Return = @"
### [$($Version.ToString())](https://github.com/$($RepositoryOwner)/$($RepositoryName)/tree/v$($Version.ToString())) ($((Get-Date -Format 'yyyy-MM-dd')))

**Features**
$($Features | ForEach-Object {"- $_`n"})
"@
    }
    
    end
    {
        return $Return
    }
}
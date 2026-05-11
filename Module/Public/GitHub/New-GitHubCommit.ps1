function New-GitHubCommit
{
    <#
    .SYNOPSIS
        Creates a commit on a GitHub repository branch via the GitHub API.
    .DESCRIPTION
        Uses the GitHub Git Data API to create a commit containing one or more file changes.
        Commits created via this method are automatically marked as Verified by GitHub,
        with no GPG or SSH signing key required.
        The Files parameter expects an array of hashtables each containing a 'Path' key
        (repo-root-relative, forward-slash separated) and a 'Content' key (raw file text).
    #>
    [CmdletBinding()]
    param
    (
        # The GitHub token used to authenticate
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GitHubToken', 'GitHubPAT')]
        [string]
        $Token,

        # The org/user that owns the repository
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GitHubOrganisation', 'GitHubOrganization', 'GitHubOrg')]
        [string]
        $RepositoryOwner,

        # The repository name
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('RepoName')]
        [string]
        $RepositoryName,

        # The branch to commit to
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $BranchName,

        # The commit message
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $CommitMessage,

        # The files to include in the commit. Each hashtable must have 'Path' and 'Content' keys.
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [hashtable[]]
        $Files
    )
    begin {}
    process
    {
        $Header = @{
            Authorization = "token $Token"
            Accept        = 'application/vnd.github.v3+json'
        }
        $BaseUri = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName"

        try
        {
            # Resolve the current HEAD commit and its tree
            $Ref = Invoke-RestMethod `
                -Uri "$BaseUri/git/ref/heads/$BranchName" `
                -Headers $Header
            $HeadSHA = $Ref.object.sha

            $HeadCommit = Invoke-RestMethod `
                -Uri "$BaseUri/git/commits/$HeadSHA" `
                -Headers $Header
            $BaseTreeSHA = $HeadCommit.tree.sha

            # Create a blob for each file and collect tree entries
            $TreeItems = foreach ($File in $Files)
            {
                $BlobBody = @{
                    content  = $File.Content
                    encoding = 'utf-8'
                } | ConvertTo-Json
                $Blob = Invoke-RestMethod `
                    -Uri "$BaseUri/git/blobs" `
                    -Method Post `
                    -Headers $Header `
                    -Body $BlobBody
                @{
                    path = $File.Path
                    mode = '100644'
                    type = 'blob'
                    sha  = $Blob.sha
                }
            }

            # Build a new tree on top of the existing one
            $TreeBody = @{
                base_tree = $BaseTreeSHA
                tree      = @($TreeItems)
            } | ConvertTo-Json -Depth 5
            $NewTree = Invoke-RestMethod `
                -Uri "$BaseUri/git/trees" `
                -Method Post `
                -Headers $Header `
                -Body $TreeBody

            # Create the commit object
            $CommitBody = @{
                message = $CommitMessage
                tree    = $NewTree.sha
                parents = @($HeadSHA)
            } | ConvertTo-Json
            $NewCommit = Invoke-RestMethod `
                -Uri "$BaseUri/git/commits" `
                -Method Post `
                -Headers $Header `
                -Body $CommitBody

            # Advance the branch ref to the new commit
            $UpdateRefBody = @{
                sha   = $NewCommit.sha
                force = $false
            } | ConvertTo-Json
            Invoke-RestMethod `
                -Uri "$BaseUri/git/refs/heads/$BranchName" `
                -Method Patch `
                -Headers $Header `
                -Body $UpdateRefBody | Out-Null
        }
        catch
        {
            throw "Failed to create commit on '$BranchName'.`n$($_.Exception.Message)"
        }
    }
    end
    {
        if ($NewCommit)
        {
            return $NewCommit
        }
        else
        {
            return $null
        }
    }
}

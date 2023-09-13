function Get-GitHubPullRequests
{
    [CmdletBinding()]
    param
    (
        # The GitHub PAT
        [Parameter(
            Mandatory = $true
        )]
        [Alias('GitHubToken', 'GitHubPAT')]
        [string]
        $Token,

        # The org name from GitHub
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [Alias('GitHubOrganisation', 'GitHubOrganization', 'GitHubOrg')]
        [string]
        $RepositoryOwner,

        # The repo name to check for PR's
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [Alias('GitHubRepo', 'RepoName')]
        [string]
        $RepositoryName,

        # Pull request state
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [GitHubIssueState]
        $State = 'open'
    )
    begin
    {}
    process
    {
        $Header = @{
            Authorization = "token $token"
            Accept        = 'application/vnd.github.v3+json'
        }
        # The GitHub API requires the state to be lowercase, our enum is uppercase
        $StateStr = ($State | Out-String).ToLower()
        $URI = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/pulls?state=$StateStr"
        Write-Verbose "Attempting to get open pull requests from $URI"
        try
        {
            # FollowReLink should give free pagination! 🎉
            $Response = Invoke-RestMethod `
                -Headers $Header `
                -Uri $URI `
                -FollowRelLink `
                -ErrorAction 'Stop' | 
                ForEach-Object { $_ } # Needed cos https://github.com/PowerShell/PowerShell/issues/5526
        }
        catch
        {
            throw "RestMethod failed: $($_.Exception.Message)"
        }
    }
    end
    {
        if ($Response)
        {
            Return $Response
        }
        else
        {
            Return $null
        }
    }
}

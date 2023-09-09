function Get-GitHubIssues
{
    [CmdletBinding()]
    param
    (
        # The GitHub PAT
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
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

        # The repository name to check for issues
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [Alias('RepoName')]
        [string]
        $RepositoryName,

        # The state of the issue
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [GitHubIssueState]
        $State = 'open'
    )
    begin
    {
    }
    process
    {
        $Header = @{
            Authorization = "token $Token"
            Accept        = 'application/vnd.github.v3+json'
        }

        # The GitHub API requires the state to be lowercase, our enum is uppercase
        $StateStr = ($State | Out-String).ToLower()
        $URI = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/issues?state=$StateStr"
        Write-Verbose "Attempting to get open issues from $URI"
        try
        {
            # FollowReLink should give free pagination! 🎉
            $Response = Invoke-RestMethod `
                -Method Get `
                -Headers $Header `
                -Uri $URI `
                -FollowRelLink `
                -ErrorAction 'Stop' |
                ForEach-Object { $_ } |
                    Where-Object { !$_.pull_request }
        }
        catch
        {
            throw "Invoke-RestMethod failed. `n$($_.Exception.Message)"
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
            return $null
        }
    }
}
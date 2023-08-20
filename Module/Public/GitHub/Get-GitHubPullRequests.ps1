function Get-GitHubPullRequests
{
    [CmdletBinding()]
    param
    (
        # The GitHub PAT
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $GitHubToken,

        # The org name from GitHub
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [Alias('GitHubOrganisation','GitHubOrganization')]
        [string]
        $GitHubOrg,

        # The repo name to check for PR's
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $RepoName,

        # Pull request state
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [GitHubPullRequestState]
        $State = 'open'
    )
    $Header = @{                                                                                                                                         
        Authorization = "token $GitHubToken"
        Accept        = 'application/vnd.github.v3+json'
    }
    # The GitHub API requires the state to be lowercase, our enum is uppercase
    $StateStr = ($State | Out-String).ToLower()
    $URI = "https://api.github.com/repos/$GitHubOrg/$RepoName/pulls?state=$StateStr"
    Write-Verbose "Attempting to get open pull requests from $URI"
    try
    {
        # FollowReLink should give free pagination! 🎉
        $Response = Invoke-RestMethod `
            -Headers $Header `
            -Uri $URI `
            -FollowRelLink `
            -ErrorAction 'Stop' | 
            ForEach-Object {$_} # Needed cos https://github.com/PowerShell/PowerShell/issues/5526
    }
    catch
    {
        throw "RestMethod failed: $($_.Exception.Message)"
    }
    if ($Response)
    {
        Return $Response
    }
    else
    {
        Return $null
    }
}
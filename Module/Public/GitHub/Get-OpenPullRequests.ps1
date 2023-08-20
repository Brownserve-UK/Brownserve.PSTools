function Get-OpenPullRequests
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
        $RepoName
    )
    Write-Warning "Get-OpenPullRequests is deprecated and will be removed in a future release.`nUse Get-GitHubPullRequests instead"
    $Header = @{                                                                                                                                         
        Authorization = "token $GitHubToken"
        Accept        = 'application/vnd.github.v3+json'
    }
    # FollowReLink should give free pagination! 🎉
    $URI = "https://api.github.com/repos/$GitHubOrg/$RepoName/pulls"
    Write-Verbose "Attempting to get open pull requests from $URI"
    try
    {
        $Response = Invoke-RestMethod -Headers $Header -Uri $URI -FollowRelLink | ForEach-Object {$_} # Needed cos https://github.com/PowerShell/PowerShell/issues/5526
    }
    catch
    {
        throw "RestMethod failed: $($_.Exception.Message)"
    }
    if ($Response)
    {
        Return $Response
    }
}
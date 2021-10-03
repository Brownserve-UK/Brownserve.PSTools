function Add-PullRequestComment
{
    [CmdletBinding()]
    param (
        # The GitHub PAT
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $GitHubToken,

        # The GitHub Organization to check
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GitHubOrganisation','GitHubOrganization')]
        [string]
        $GitHubOrg,

        # The ID of the Pull Request
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $PullRequestID,

        # The comment to be added to the PR
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $PullRequestComment,

        # The name of the repo
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $RepoName
    )
    $Header = @{                                                                                                                                         
        Authorization = "token $GitHubToken"
        Accept        = 'application/vnd.github.v3+json'
    }
    $URI = "https://api.github.com/repos/$GitHubOrg/$RepoName/issues/$PullRequestID/comments"
    $Body = @{
        body = $PullRequestComment
    }
    try
    {
        $BodyJSON = $Body | ConvertTo-Json
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
    Write-Verbose "Attempting to add comment to pull request $PullRequestID"
    try
    {
        $Update = Invoke-RestMethod -Headers $Header -Uri $URI -Body $BodyJSON -Method Post
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
    Return $Update
}
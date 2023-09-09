function Add-PullRequestComment
{
    [CmdletBinding()]
    param (
        # The GitHub PAT
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GitHubToken', 'GitHubPAT')]
        [string]
        $Token,

        # The owner of the repository
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GitHubOrganisation', 'GitHubOrganization', 'GitHubOrg')]
        [string]
        $RepositoryOwner,

        # The ID of the Pull Request
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $PullRequestID,

        # The comment to be added to the PR
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $PullRequestComment,

        # The repository name
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('RepoName')]
        [string]
        $RepositoryName
    )
    begin
    {}
    process
    {
        $Header = @{
            Authorization = "token $Token"
            Accept        = 'application/vnd.github.v3+json'
        }
        $URI = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/issues/$PullRequestID/comments"
        $Body = @{
            body = $PullRequestComment
        }
        try
        {
            $BodyJSON = $Body | ConvertTo-Json
        }
        catch
        {
            throw $_.Exception.Message
        }
        Write-Verbose "Attempting to add comment to pull request $PullRequestID"
        try
        {
            $Update = Invoke-RestMethod -Headers $Header -Uri $URI -Body $BodyJSON -Method Post
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    end
    {
        if ($Update)
        {
            Return $Update
        }
        else
        {
            Return $null
        }
    }
}

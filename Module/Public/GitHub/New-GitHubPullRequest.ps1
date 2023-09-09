function New-GitHubPullRequest
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

        # The org name from GitHub
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('GitHubOrganisation', 'GitHubOrganization', 'GitHubOrg')]
        [string]
        $RepositoryOwner,

        # The body of the pull request
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $Body,

        # The title of the pull request
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $Title,

        # The branch you want to pull changes into
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $BaseBranch,

        # Your feature branch that you want to merge into your base branch
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]
        $HeadBranch,

        # The repository name to check for issues
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('RepoName')]
        [string]
        $RepositoryName
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
        $URI = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/pulls"
        $BodyObj = @{
            title = $Title
            body  = $Body
            base  = $BaseBranch
            head  = $HeadBranch
        }
        try
        {
            $BodyJSON = $BodyObj | ConvertTo-Json
        }
        catch
        {
            Write-Error "Failed to convert PR body to JSON.`n$($_.Exception.Message)"
        }
        Write-Verbose "Attempting to raise PR at $URI"
        try
        {
            $Request = Invoke-RestMethod -Headers $Header -Uri $URI -Body $BodyJSON -Method Post
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }
    end
    {
        if ($Request)
        {
            Return $Request
        }
        else
        {
            return $null
        }
    }
}

function New-PullRequest
{
    [CmdletBinding()]
    param (       
        # The GitHub PAT
        [Parameter(
            Mandatory = $true
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

        # The body of the pull request
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $PRBody,

        # The title of the pull request
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $PRTitle,

        # The branch you want to pull changes into
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [string]
        $BaseBranch,

        # Your feature branch that you want to merge into your base branch
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [string]
        $HeadBranch,

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
    $URI = "https://api.github.com/repos/$GitHubOrg/$RepoName/pulls"
    $Body = @{
        title = $PRTitle
        body  = $PRBody
        base  = $BaseBranch
        head  = $HeadBranch
    }
    try
    {
        $BodyJSON = $Body | ConvertTo-Json
    
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
    Return $Request
}
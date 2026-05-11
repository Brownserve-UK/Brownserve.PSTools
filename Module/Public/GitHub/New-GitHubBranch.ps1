function New-GitHubBranch
{
    <#
    .SYNOPSIS
        Creates a new remote branch in a GitHub repository.
    .DESCRIPTION
        Uses the GitHub Git Data API to create a branch from a given commit SHA.
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

        # The name of the branch to create
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $BranchName,

        # The commit SHA to branch from
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $SHA
    )
    begin {}
    process
    {
        $Header = @{
            Authorization = "token $Token"
            Accept        = 'application/vnd.github.v3+json'
        }
        $Body = @{
            ref = "refs/heads/$BranchName"
            sha = $SHA
        } | ConvertTo-Json

        try
        {
            $Response = Invoke-RestMethod `
                -Uri "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/git/refs" `
                -Method Post `
                -Headers $Header `
                -Body $Body
        }
        catch
        {
            throw "Failed to create branch '$BranchName'.`n$($_.Exception.Message)"
        }
    }
    end
    {
        if ($Response)
        {
            return $Response
        }
        else
        {
            return $null
        }
    }
}

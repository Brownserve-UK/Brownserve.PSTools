function Get-GitHubTags
{
    [CmdletBinding()]
    param
    (
        # The GitHub repo to create the release against
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [Alias('RepoName')]
        [string]
        $RepositoryName,

        # The organisation that the repo lives in
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [Alias('GitHubOrganisation', 'GitHubOrganization', 'GitHubOrg')]
        [string]
        $RepositoryOwner,

        # The PAT to access the repo
        [Parameter(
            Mandatory = $true
        )]
        [Alias('GitHubToken', 'GitHubPAT')]
        [string]
        $Token
    )
    begin
    {}
    process
    {
        $Header = @{
            Authorization = "token $Token"
            Accept        = 'application/vnd.github.v3+json'
        }
        $URI = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/tags"

        Write-Verbose "Attempting to fetch tags from $URI"
        try
        {
            $Request = Invoke-RestMethod -Headers $Header -Uri $URI -Method Get -FollowRelLink | ForEach-Object { $_ } # Needed because of https://github.com/PowerShell/PowerShell/issues/5526
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }
    end
    {
        Return $Request
    }
}

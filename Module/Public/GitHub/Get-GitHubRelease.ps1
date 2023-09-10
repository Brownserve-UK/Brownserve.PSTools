function Get-GitHubRelease
{
    [CmdletBinding()]
    param
    (
        # The org name from GitHub
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
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

        # The GitHub PAT
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
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
        $URI = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/releases"

        Write-Verbose "Attempting to fetch releases from $URI"
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

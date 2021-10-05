function Get-GitHubRelease
{
    [CmdletBinding()]
    param
    (
        # The GitHub repo to create the release against
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $RepoName,

        # The organisation that the repo lives in
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [Alias('GitHubOrganisation','GitHubOrganization')]
        [string]
        $GitHubOrg,

        # The PAT to access the repo
        [Parameter(
            Mandatory = $true
        )]
        [string]
        $GitHubToken
    )
    $Header = @{                                                                                                                                         
        Authorization = "token $GitHubToken"
        Accept        = 'application/vnd.github.v3+json'
    }
    $URI = "https://api.github.com/repos/$GitHubOrg/$RepoName/releases"

    Write-Verbose "Attempting to fetch releases from $URI"
    try
    {
        $Request = Invoke-RestMethod -Headers $Header -Uri $URI -Method Get -FollowRelLink | Foreach-Object { $_ } # Needed because of https://github.com/PowerShell/PowerShell/issues/5526
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
    Return $Request
}

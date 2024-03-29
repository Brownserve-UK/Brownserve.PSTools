function New-GitHubRelease
{
    [CmdletBinding()]
    param
    (
        # The name of the release
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Name,

        # The tag to use for the release, should not contain any whitespace.
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string]
        $Tag,

        # The description for this release
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string]
        $Description,

        # The GitHub repo to create the release against
        [Parameter(
            Mandatory = $true,
            Position = 3
        )]
        [Alias('RepoName')]
        [string]
        $RepositoryName,

        # The Organization that the repo lives in
        [Parameter(
            Mandatory = $true,
            Position = 4
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
        $Token,

        # Set if this is a prerelease
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $Prerelease,

        # The target commitish to use (if any)
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $TargetCommit
    )
    begin {}
    process
    {
        if ($Tag -match '\s')
        {
            throw "Tag $Tag contains whitespace"
        }
        $Header = @{
            Authorization = "token $Token"
            Accept        = 'application/vnd.github.v3+json'
        }
        $URI = "https://api.github.com/repos/$RepositoryOwner/$RepositoryName/releases"
        $Body = @{
            tag_name = $Tag
            name     = $Name
            body     = $Description
        }
        if ($Prerelease)
        {
            $Body.Add('prerelease', $true)
        }
        if ($TargetCommit)
        {
            $Body.Add('target_commitish', $TargetCommit)
        }
        try
        {
            $BodyJSON = $Body | ConvertTo-Json
        }
        catch
        {
            Write-Error "Failed to convert PR body to JSON.`n$_.Exception.Message"
        }
        Write-Verbose "Attempting to create release $Tag at $URI"
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
        Return $Request
    }
}

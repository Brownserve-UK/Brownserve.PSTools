<#
.SYNOPSIS
    Uploads a file to a GitHub release.
.DESCRIPTION
    Uploads a file to a GitHub release.
#>
function Add-GitHubReleaseAsset
{
    [CmdletBinding()]
    param
    (
        # The path to the file to upload.
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $FilePath,

        # Determines the name of the asset on GitHub (remember to include the extension!)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $AssetName = (Split-Path $FilePath -Leaf),

        # An optional label for the asset, used in place of the file name.
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $AssetLabel,

        # The upload URL for the release.
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $UploadUrl,

        # The GitHub API token to use.
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Token
    )
    begin
    {
    }
    process
    {
        $Headers = @{
            Accept                 = 'application/vnd.github+json'
            Authorization          = "Bearer $Token"
            'X-GitHub-Api-Version' = '2022-11-28'
            'Content-Type'         = 'application/octet-stream' #TODO: Should this be hardcoded?
        }

        try
        {
            $FileToUpload = Get-Item $FilePath -Force -ErrorAction Stop
        }
        catch
        {
            throw "Unable to find file '$FilePath'."
        }

        <#
            By default the `upload_url` property returned by the releases API looks like
            https://uploads.github.com/repos/[OWNER]/[REPO]/releases/[RELEASE_ID]/assets{?name,label}
            If we're using that URL then we need to chop off the end of it
        #>
        if ($UploadUrl -match '\{\?.*\}')
        {
            $UploadUrl = $UploadUrl | Split-Path
        }
        $UploadUrl += "/assets?name=$AssetName"
        if ($AssetLabel)
        {
            $UploadUrl += "&label=$AssetLabel"
        }
        $Form = @{
            file = $FileToUpload
        }

        try
        {
            $Result = Invoke-RestMethod -Uri $UploadUrl -Method Post -Headers $Headers -Form $Form -ErrorAction Stop
        }
        catch
        {
            throw "Unable to upload file '$FilePath' to '$UploadUrl'.`n$($_.Exception.Message)"
        }
    }
    end
    {
        if ($Result)
        {
            return $Result
        }
        else
        {
            return $null
        }
    }
}

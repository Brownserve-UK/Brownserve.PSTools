function Publish-TeamcityArtifact
{
    [CmdletBinding()]
    param (
        # The artifact you wish to publish
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $ArtifactPath,

        # The target directory to publish the artifact to (optional)
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [string]
        $TargetDirectory
    )
    if ((Test-Path $ArtifactPath) -ne $true)
    {
        Write-Error "Artifact path $ArtifactPath is not valid"
    }
    Write-Verbose "Publishing $ArtifactPath as an artifact"
    Write-Host "##teamcity[publishArtifacts '$ArtifactPath'$(if($TargetDirectory){"=> $TargetDirectory"})]"
}
function Set-TeamcityBuildNumber
{
    [CmdletBinding()]
    param
    (
        # The build number to be set
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $BuildNumber,

        # If set this will append the current Teamcity build number
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $AppendCurrentBuildNumber
    )
    Write-Host "##teamcity[buildNumber '$BuildNumber$(if ($AppendCurrentBuildNumber){"_{build.number}"})']"
}
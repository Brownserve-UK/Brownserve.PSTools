function Write-TeamcityStatus
{
    [CmdletBinding()]
    param (
       # The message you want displayed in TeamCity
       [Parameter(
           Mandatory = $true,
           Position = 0
       )]
       [string]
       $Message
    )
    Write-Warning "This cmdlet is deprecated and will be removed in a future release."
    $Message = $Message -replace "`n","" -replace "`r",""
    Write-Host $Message
    Write-Host "##teamcity[buildStatus text='$Message - {build.status.text}']"
}
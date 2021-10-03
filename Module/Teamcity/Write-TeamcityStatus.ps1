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
    $Message = $Message -replace "`n","" -replace "`r",""
    Write-Host $Message
    Write-Host "##teamcity[buildStatus text='$Message - {build.status.text}']"
}
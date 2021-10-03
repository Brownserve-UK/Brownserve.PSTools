function Write-TeamcityBuildProblem
{
    [CmdletBinding()]
    param (
        # The message you want displayed in TeamCity
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Message,

        # If set to true this will throw an exception instead of writing to StdErr.
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $TerminatingError
    )
    $Message = $Message -replace "`n", "" -replace "`r", ""
    Write-Host "##teamcity[buildProblem description='$Message']" -ForegroundColor Red
    if ($TerminatingError)
    {
        throw $Message
    }
    else
    {
        Write-Error $Message
    }
}
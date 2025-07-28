<#
.SYNOPSIS
    Ensures a given path exists.
.DESCRIPTION
    This cmdlet will check for the presence of a given path and raise an exception if it cannot be found.
    Inversely if you pass the '-Inverse' an exception will be raised if the path DOES exist.
#>
function Assert-Path
{
    [CmdletBinding()]
    param
    (
        # The path to check
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string[]]
        $Path,

        # If specified will raise an exception if the path exists
        [Parameter(Mandatory = $false)]
        [switch]
        $Inverse
    )
    begin
    {
    }
    process
    {
        $PathErrors = @()
        $Path | ForEach-Object {
            if (Test-Path $_)
            {
                if ($Inverse)
                {
                    $PathErrors += $_
                }
            }
            else
            {
                if (!$Inverse)
                {
                    $PathErrors += $_
                }
            }
        }
    }
    end
    {
        if ($PathErrors)
        {
            if ($Inverse)
            {
                throw "The following paths already exist:`n$($PathErrors -join "`n")"
            }
            else
            {
                throw "The following paths do not exist:`n$($PathErrors -join "`n")"
            }
        }
    }
}

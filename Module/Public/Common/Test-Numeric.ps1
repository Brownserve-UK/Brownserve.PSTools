<#
.SYNOPSIS
    Tests if a given object is numeric.
#>
function Test-Numeric
{
    [CmdletBinding()]
    param
    (
        # The object to test
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [psobject]
        $InputObject
    )
    begin
    {
    }
    process
    {
        if ($InputObject -is [int] -or $InputObject -is [Int16] -or $InputObject -is [Int64] -or $InputObject -is [System.Int128] -or $InputObject -is [long] -or $InputObject -is [decimal] -or $InputObject -is [double] -or $InputObject -is [float])
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    end
    {
    }
}

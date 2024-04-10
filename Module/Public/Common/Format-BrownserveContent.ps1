<#
.SYNOPSIS
    Formats a given string to be compatible with the various *-BrownserveContent cmdlets.
.DESCRIPTION
    This cmdlet will take a string and format it so that it can be easily used with the *-BrownserveContent cmdlets.
    This allows us to ensure files get written with the correct formatting and works around PowerShells inconsistent
    line ending handling between Windows and Linux.
#>
function Format-BrownserveContent
{
    [CmdletBinding()]
    param
    (
        # The content to format, should be a single string with each line separated by a newline character
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [string]
        $Content,

        # If true inserts a final newline if one is not present
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [bool]
        $InsertFinalNewline = $true,

        # The line ending to use
        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [BrownserveLineEnding]
        $LineEnding = 'LF'
    )

    begin
    {
        $Return = @()
    }

    process
    {
        # Split the content into lines and remove any carriage returns, line endings will be handled
        # by BrownserveContent class
        $SplitContent = $Content -split "`n"
        $SplitContent = $SplitContent -replace "`r", ''

        if ($InsertFinalNewline -and $SplitContent[-1] -ne '')
        {
            $SplitContent += ''
        }

        $Return += [pscustomobject]@{
            Content = $SplitContent
            LineEnding = $LineEnding
        }
    }

    end
    {
        if ($Return.Count -gt 0)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}

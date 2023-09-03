<#
.SYNOPSIS
    This cmdlet removes markdown from a string.
.DESCRIPTION
    This cmdlet removes markdown from a string.
#>
function Remove-Markdown
{
    [CmdletBinding()]
    param
    (
        # The string to remove markdown from.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string[]]
        $String
    )
    begin
    {
        $Return = @()
    }
    process
    {
        $String | ForEach-Object {
            $Return += $_ `
                -replace '\*\*(.*?)\*\*', '$1' `
                -replace '\*(.*?)\*', '$1' `
                -replace '\`(.*?)\`', '$1' `
                -replace '\~\~(.*?)\~\~', '$1' `
                -replace '__(.*?)__', '$1' `
                -replace '_(.*?)_', '$1' `
                -replace '\!\[(.*?)\]\((.*?)\)', '$1' `
                -replace '\[(.*?)\]\((.*?)\)', '$1' `
                -replace '\#\#\#(.*?)\#\#\#', '$1' `
                -replace '\#\#(.*?)\#\#', '$1' `
                -replace '\#(.*?)\#', '$1' `
                -replace '\>(.*?)\n', "`$1`n"
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

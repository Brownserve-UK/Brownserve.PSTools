<#
.SYNOPSIS
    Writes the contents of a file to disk.
.DESCRIPTION
    This cmdlet is effectively just a wrapper around the Set-Content cmdlet. It allows us to maintain a complete
    pipeline for working with file content.
#>
function Set-BrownserveContent
{
    [CmdletBinding()]
    param
    (
        # The content object to write to disk
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [BrownserveContent[]]
        $InputObject
    )
    begin
    {

    }
    process
    {
        foreach ($Object in $InputObject)
        {
            try
            {
                <#
                    The ToString() method on the BrownserveContent class will return the content of the file with
                    the line endings in the format specified by the LineEnding property.
                    This ensures the line endings are correct when writing the file to disk.
                #>
                Set-Content `
                    -Path $Object.Path `
                    -Value $Object.ToString() `
                    -NoNewline `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to write content to file '$($Object.Path)'.`n$($_.Exception.Message)"
            }
        }
    }
    end
    {
    }
}

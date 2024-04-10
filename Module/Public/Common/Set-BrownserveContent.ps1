<#
.SYNOPSIS
    Writes the contents of a file to disk.
.DESCRIPTION
    This cmdlet is effectively just a wrapper around the Set-Content cmdlet. It allows us to maintain a complete
    pipeline for working with file content.
#>
function Set-BrownserveContent
{
    [CmdletBinding(
        DefaultParameterSetName = 'Default'
    )]
    param
    (
        # The path to the file(s) to write
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Default'
        )]
        [Alias('PSPath')]
        [string[]]
        $Path,

        # The content to write to the file, should be an array of strings without any new line characters
        [Parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Default'
        )]
        [Alias('Value')]
        [string[]]
        $Content,

        # The line ending to use
        [Parameter(
            Mandatory = $false,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Default'
        )]
        [BrownserveLineEnding]
        $LineEnding = 'LF',

        # Whether or not to insert a final newline if one is not present
        [Parameter(
            Mandatory = $false,
            Position = 3,
            ParameterSetName = 'Default'
        )]
        [bool]
        $InsertFinalNewline = $true
    )
    begin
    {

    }
    process
    {
        $Path | ForEach-Object {
            <#
                We expect the '-Content' parameter to be an array of strings without any new line characters.
                However it's all too easy for a user to build up a string using concatenation with line endings
                and then assume that the string will be written to disk as is.
                This goes against the very nature of _why_ we wrote this cmdlet, to ensure that the line endings
                are consistent across all files!
                It's also entirely possible the user has correctly split the content on new lines but hasn't
                realised that the carriage return characters remain.
                So we check the content for line endings and if we find any we warn the user and remove them.
            #>
            if ($Content -match '\n|\r')
            {
                Write-Warning "The content for file '$_' already contains line endings.`nThese will be replaced with the specified '$LineEnding' line ending."
                <#
                        If we simply remove the new line characters from the content then we will end up with a single string which is
                        almost certainly not what the user will have intended.
                        So we split the content on new lines and remove any residual carriage returns.
                    #>
                $Content = $Content -split "`n"
                $Content = $Content -replace '\r', ''
            }
            # If the content has a final new line it will be an empty string
            if (($InsertFinalNewline -eq $true) -and ('' -ne $Content[-1]))
            {
                $Content += ''
            }
            $ContentObject = [BrownserveContent]@{
                Path       = $_
                Content    = $Content
                LineEnding = $LineEnding
            }

            try
            {
                <#
                    The ToString() method on the BrownserveContent class will return the content of the file with
                    the line endings in the format specified by the LineEnding property.
                    This ensures the line endings are correct when writing the file to disk.
                    We also use the -NoNewline parameter to ensure that we don't add an extra newline to the end of the file as
                    this will use the system default line ending (CR LF on Windows, LF on Unix, etc.) which may lead to
                    inconsistent line endings in the file.
                #>
                Set-Content `
                    -Path $ContentObject.Path `
                    -Value $ContentObject.ToString() `
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

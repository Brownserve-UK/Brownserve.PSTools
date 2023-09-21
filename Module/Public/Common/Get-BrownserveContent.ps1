<#
.SYNOPSIS
    Wrapper for Get-Content that returns the content in a format that is easier to work with.
.DESCRIPTION
    This cmdlet ensures that any content is returned in a format that is easy to work with in pipelines.
    It stores the content as a string array so it can be easily iterated over while stripping any line breaks.
    It also detects the line endings of the file and stores that information in the returned object so the file can
    be saved with the same line endings.
#>
function Get-BrownserveContent
{
    [CmdletBinding()]
    param
    (
        # The path to the file to get content from
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [Alias('PSPath')]
        [string[]]
        $Path
    )

    begin
    {
        $Return = @()
    }

    process
    {
        try
        {
            $Path | ForEach-Object {
                # Store the content without line breaks, it's easier to work with
                $Content = Get-Content -Path $_ -ErrorAction 'Stop' -ReadCount 0
                # Read the content as a byte stream so we can properly detect the line endings
                # TODO: do we do this before getting the content without line breaks?
                # If we do it before then we can ensure the delimiter is set to the correct line ending?
                $ByteStreamContent = Get-Content -Path $_ -ErrorAction 'Stop' -Raw -AsByteStream
                $LFCount = 0
                $CRCount = 0
                foreach ($Byte in $ByteStreamContent)
                {
                    # A LF byte is 10, a CR byte is 13
                    if ($Byte -eq 10)
                    {
                        $LFCount++
                    }
                    elseif ($Byte -eq 13)
                    {
                        $CRCount++
                    }
                }
                # Check to see if we have any carriage returns
                if ($CRCount -gt 0)
                {
                    # If we do then check to see if we have any line feeds as well
                    if ($LFCount -gt 0)
                    {
                        # If we have the same number of carriage returns and line feeds then we have a CRLF file
                        if ($CRCount -eq $LFCount)
                        {
                            $LineEnding = 'CRLF'
                        }
                        <#
                            Looks like we have a file with mixed line endings 😬
                            We'll set it to use our default line ending of LF and warn the user that the
                            Set-BrownserveContent cmdlet will save the file with the new line endings.
                            (This can be overridden by specifying the -LineEnding parameter when calling Format-BrownserveContent)
                        #>
                        else
                        {
                            $LineEnding = 'LF'
                            Write-Warning -Message "File '$_' has mixed line endings.`nIf this file is updated using 'Set-BrownserveContent' then it will be saved with '$LineEnding' line endings.`nUse 'Format-BrownserveContent' with the '-LineEnding' parameter before calling 'Set-BrownserveContent' to manually set the line endings."
                        }
                    }
                    # Very unlikely but if we don't have any line feeds then we have a file with just carriage returns
                    else
                    {
                        $LineEnding = 'CR'
                    }
                }
                else
                {
                    # Hopefully the file has line feeds, otherwise we have a file with no line endings 😬
                    if ($LFCount -gt 0)
                    {
                        $LineEnding = 'LF'
                    }
                    <#
                        Somehow we have a file with no line endings!?
                        It's possible this file is just one line, in which case we'll set it to use our
                        default line ending of LF.
                    #>
                    else
                    {
                        $LineEnding = 'LF'
                    }
                }
                $Path = Get-Item -Path $_ -ErrorAction 'Stop'
                $Return += [BrownserveContent]@{
                    Content    = $Content
                    Path       = $Path
                    LineEnding = $LineEnding
                }
            }
        }
        catch
        {
            throw "Failed to get content from path '$_'.`n$($_.Exception.Message)"
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

<#
.SYNOPSIS
    Formats the contents of a file.
.DESCRIPTION
    When working with file content sometimes it is necessary to alter the format of the file before it is
    written to disk. This cmdlet allows you to do that by specifying various options of how the file should
    be formatted.
    This cmdlet should typically be used just before calling Set-BrownserveContent to write the file to disk.
#>
function Format-BrownserveContent
{
    [CmdletBinding(
        DefaultParameterSetName = 'Default'
    )]
    param
    (
        # The path to the file to search
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'Path'
        )]
        [Alias('PSPath')]
        [string[]]
        $Path,

        # The content to search
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName = 'Content'
        )]
        [BrownserveContent[]]
        $InputObject,

        # If true inserts a final newline if one is not present
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [bool]
        $InsertFinalNewline = $true,

        # The line ending to use, if not specified will use the current line ending from the file
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [BrownserveLineEnding]
        $LineEnding
    )

    begin
    {
        $Return = @()
    }

    process
    {
        if (!$InputObject)
        {
            try
            {
                Write-Verbose 'Loading content from files'
                $Path | ForEach-Object {
                    $InputObject += Get-BrownserveContent -Path $_ -ErrorAction 'Stop'
                }
            }
            catch
            {
                throw "Failed to get content from path '$_'.`n$($_.Exception.Message)"
            }
        }

        foreach ($item in $InputObject)
        {
            $Content = $Item.Content
            # The content should be an array of strings so we can add a $null to the end
            if ($InsertFinalNewline -and ($null -ne $Content[-1]))
            {
                $Content += $null
            }

            $Return += [BrownserveContent]@{
                Content    = $Content
                LineEnding = $LineEnding
                Path       = $Item.Path
            }
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

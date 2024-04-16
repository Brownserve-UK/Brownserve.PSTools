<#
.SYNOPSIS
    Selects text from a given file
.DESCRIPTION
    This cmdlet will select text from a given file.
    You can specify a `After` and/or `Before` parameter to select text between two points
    these can be either a line number or a string/regex.
    You can pipe content from Get-BrownserveContent into this cmdlet.
#>
function Select-BrownserveContent
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

        # The BrownserveContent object
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            ParameterSetName = 'Content',
            DontShow = $true
        )]
        [BrownserveContent[]]
        $InputObject,

        # If passed then only content after this line will be returned
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [psobject]
        $After,

        # If passed then only content before this line will be returned
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [psobject]
        $Before,

        # If specified will raise an exception if no results are found
        [Parameter(Mandatory = $false)]
        [switch]
        $FailIfNotFound
    )
    begin
    {
        $Return = @()
    }
    process
    {
        <#
            If we don't have any content, then we need to get it from the file.
            Both of these parameters are mandatory for their respective parameter sets so we should end up with at least one.
        #>
        if (!$InputObject)
        {
            try
            {
                $Path | ForEach-Object {
                    Write-Verbose "Loading content from $_"
                    $InputObject += Get-BrownserveContent -Path $_ -ErrorAction 'Stop'
                }
            }
            catch
            {
                throw "Failed to get content from path '$_'.`n$($_.Exception.Message)"
            }
        }

        foreach ($Item in $InputObject)
        {
            $NotFoundError = @()
            $TextToReturn = $null
            $BeginTextLine = $null
            $EndTextLine = $null
            <#
                The content returned from Get-BrownserveContent is an array of strings
                so we don't need to worry about splitting it.
            #>
            $SplitContent = $Item.Content
            $LastLine = $SplitContent.Count

            <#
                We only bother trying to extract text if we have more than one line.
                Our method of extracting text relies on the line number, so if we only have one line
                then we can't extract anything.
            #>
            if ($LastLine -gt 1)
            {
                if ($null -ne $After)
                {
                    <#
                        If the `After` parameter is a number then we start from that line.
                    #>
                    if ((Test-Numeric $After))
                    {
                        $BeginTextLine = $After
                    }
                    <#
                        Otherwise assume it's a string/regex and search for it.
                    #>
                    else
                    {
                        <#
                            The LineNumber property starts at 1, but the array of text starts at 0.
                            So this should mean we get the correct line as we want to return text AFTER the
                            line we are searching for.
                        #>
                        $BeginTextLine = $SplitContent |
                            Select-String -Pattern $After -SimpleMatch -AllMatches |
                                Select-Object -ExpandProperty LineNumber -First 1

                        <#
                            We don't fail at this point as we may have a `Before` parameter so we wait until
                            we've checked that too.
                            That way we can report both errors at the same time.
                        #>
                        if ($FailIfNotFound -and ($null -eq $BeginTextLine))
                        {
                            $NotFoundError += "The expression '$After' could not be found in the content."
                        }
                        else
                        {
                            Write-Debug "BeginTextLine: $BeginTextLine"
                        }
                    }
                }
                else
                {
                    # If the `After` parameter is not set then we just start from the first line
                    $BeginTextLine = 0
                }

                if ($null -ne $Before)
                {
                    if ((Test-Numeric $Before))
                    {
                        $EndTextLine = $Before
                    }
                    else
                    {
                        $EndTextLine = $SplitContent |
                            Select-String -Pattern $Before -SimpleMatch -AllMatches |
                                Select-Object -ExpandProperty LineNumber -First 1
                        <#
                            The LineNumber property starts at 1, but the array of text starts at 0.
                            So we need to wind back 2 lines, one because of the offset and one because we want to return
                            text from BEFORE the matched line.
                        #>
                        $EndTextLine = $EndTextLine - 2

                        if ($FailIfNotFound -and ($null -eq $EndTextLine))
                        {
                            $NotFoundError += "The expression '$Before' could not be found in the content."
                        }
                        else
                        {
                            Write-Debug "EndTextLine: $EndTextLine"
                        }
                    }
                }
                else
                {
                    # If the `Before` parameter is not set then we just go to the last line
                    $EndTextLine = $LastLine
                }
            }
            else
            {
                # TODO: Implement single line handling
                if ($FailIfNotFound)
                {
                    $NotFoundError += 'The content has only one line, so no text can be extracted.'
                }
            }

            if ($NotFoundError.Count -gt 0)
            {
                throw $NotFoundError
            }

            if ($BeginTextLine -and $EndTextLine)
            {
                <#
                    Due to the way we work out the start and end of the text block we want to return we can end up in a couple
                    of undesirable situations:

                    - We can end up with a BeginTextLine that is >= the EndTextLine this can happen when there is no
                    text or whitespace between the start and stop strings. (e.g ##Start`n##Stop)
                    - We can end up with a BeginTextLine that is the same as the EndTextLine, this can happen when
                    there is no text or only whitespace after the start string. (e.g. ##Start`n`n##Stop)

                    We don't count these as errors as we've actually found both the start and stop strings it's just
                    that there is no content to extract.
                    So we'll just return an empty string (which is distinct from $null)
                #>
                if ($BeginTextLine -ge $EndTextLine)
                {
                    Write-Verbose 'BeginTextLine is greater than or equal to EndTextLine, returning empty string'
                    $TextToReturn = ''
                }
                if ($BeginTextLine -eq $EndTextLine)
                {
                    Write-Verbose 'BeginTextLine is equal to EndTextLine, returning empty string'
                    $TextToReturn = ''
                }
                if ($null -eq $TextToReturn)
                {
                    $TextToReturn = $SplitContent[$BeginTextLine..$EndTextLine]
                }
            }

            if ($null -ne $TextToReturn)
            {
                $Return += [BrownserveContent]@{
                    Path       = $Item.Path
                    Content    = $TextToReturn
                    LineEnding = $Item.LineEnding
                }
            }
            else
            {
                <#
                    If we've not found anything then don't return anything.
                    This follows the behaviour of Select-String which will return $null if the string is not found
                #>
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

function Select-StringBetween
{
    [CmdletBinding(
        DefaultParameterSetName = 'Default'
    )]
    param
    (
        # Return all the lines after this expression
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $AfterExpression,

        # Return all the lines before this expression
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $BeforeExpression,

        # Returns a string instead of an array
        [Parameter(Mandatory = $false)]
        [switch]
        $AsString,

        # If specified will raise an exception if no text is found
        [Parameter(Mandatory = $false)]
        [switch]
        $FailIfNotFound,

        # The text to search between
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [string[]]
        $InputObject
    )
    begin
    {
        # No point returning the whole file...
        if (!$AfterExpression -and !$BeforeExpression)
        {
            throw "You must specify either the 'AfterExpression' or 'BeforeExpression' parameter."
        }
        # Needed when piping, see below
        $CompleteText = @()
    }
    process
    {
        <#
            When piping content PowerShell will always process the pipeline one object at a time.
            That's of no use to use because we work with an array of strings and the
        #>
        if ($InputObject)
        {
            $InputObject | ForEach-Object { $CompleteText += $_ }
        }
    }
    end
    {

        $NotFoundError = @()
        $TextToReturn = $null
        $LineCount = 0
        $StartStringLine = $null
        $StopStringLine = $null
        $StartOffset = 1
        $StopOffset = -1
        # If we've not specified the AfterExpression parameter we assume the user wants to get the entire file from the start
        if (!$AfterExpression)
        {
            Write-Debug 'No AfterExpression string provided, using start of file'
            $StartStringLine = 0
            $StartOffset = 0
        }
        # If there's not stop string pattern we assume the user wants to get the entire rest of the file, so we go until the last line
        if (!$BeforeExpression)
        {
            Write-Debug 'No stop string provided, using end of file'
            $StopStringLine = $CompleteText.Count
            $StopOffset = 0
        }

        # We can only go line-by-line if there are multiple lines
        if ($CompleteText.Count -gt 1)
        {
            $CompleteText | ForEach-Object {
                $Line = $_.Trim()
                $LineMatch = $null
                # Have disabled the below debugging, it's very very verbose 😬
                # Write-Debug "Line: $LineCount`nContents:$Line"
                if ($AfterExpression)
                {
                    if ($null -eq $StartStringLine)
                    {
                        $LineMatch = [regex]::Match($Line, $AfterExpression)
                        if ($LineMatch.Success)
                        {
                            Write-Verbose "Found match to '$AfterExpression' on line $LineCount"
                            $StartStringLine = $LineCount
                        }
                    }
                }
                if ($BeforeExpression)
                {
                    if ($null -eq $StopStringLine)
                    {
                        $LineMatch = [regex]::Match($Line, $BeforeExpression)
                        if ($LineMatch.Success)
                        {
                            Write-Verbose "Found match to '$BeforeExpression' on line $LineCount"
                            $StopStringLine = $LineCount
                        }
                    }
                }
                $LineCount++
            }

            if ($null -ne $StartStringLine)
            {
                # We want to get the line after the starting string
                $TextBlockStartLine = $StartStringLine + $StartOffset
            }
            else
            {
                <#
                    If the user has specified a 'AfterExpression' string but we can't find it in the file then we should fail.
                #>
                if ($AfterExpression -and $FailIfNotFound)
                {
                    $NotFoundError += "The AfterExpression expression '$AfterExpression' resulted in no matches."
                }
            }
    
            if ($null -ne $StopStringLine)
            {
                # We want to get the line before the stopping string
                $TextBlockStopLine = $StopStringLine + $StopOffset
            }
            else
            {
                <#
                    If the user has specified a 'BeforeExpression' string but we can't find it in the file then we should fail.
                #>
                if ($BeforeExpression -and $FailIfNotFound)
                {
                    $NotFoundError += "The BeforeExpression expression '$BeforeExpression' resulted in no matches."
                }
            }
    
            # We can only return text if we have both a start and stop line
            if ($TextBlockStartLine -and $TextBlockStopLine)
            {
                try
                {
                    <#
                        Due to the way we work out the start and end of the text block we want to return we can end up in a couple
                        of undesirable situations:
    
                        - We can end up with a TextBlockStartLine that is >= the StopStringLine this can happen when there is no
                        text or whitespace between the start and stop strings. (e.g ##Start`n##Stop)
                        - We can end up with a TextBlockStartLine that is the same as the TextBlockStopLine, this can happen when
                        there is no text or only whitespace after the start string. (e.g. ##Start`n`n##Stop)
    
                        We don't count these as errors as we've actually found both the start and stop strings it's just
                        that there is no content to extract.
                        So we'll just return an empty string (which is distinct from $null)
                    #>
                    if ($TextBlockStartLine -ge $StopStringLine)
                    {
                        Write-Verbose 'TextBlockStartLine is ahead of StopStringLine'
                        $TextToReturn = ''
                    }
                    if ($TextBlockStartLine -eq $TextBlockStopLine)
                    {
                        Write-Verbose 'TextBlockStartLine and TextBlockStopLine are the same'
                        $TextToReturn = ''
                    }
                    # Only try to do this if we haven't already met one of the conditions above
                    if ($null -eq $TextToReturn)
                    {
                        if ($TextBlockStartLine -ne $TextBlockStopLine)
                        {
                            $TextToReturn = $CompleteText[$TextBlockStartLine..$TextBlockStopLine]
                            if (!$TextToReturn)
                            {
                                throw 'TextToReturn is an empty object'
                            }
                        }
                    }
                }
                catch
                {
                    throw "Failed to extract text.`n$($_.Exception.Message)"
                }
            }
            else
            {
                if ($FailIfNotFound)
                {
                    throw "Failed to find text in file.`n$($NotFoundError -join "`n")"
                }
            }
    
        }
        else
        {
            # This regex should capture everything
            $SingleMatch = '([\s\S]*)'
            $SingleString = $CompleteText[0]
            if ($AfterExpression)
            {
                $SingleMatch = $AfterExpression + $SingleMatch
                if ($SingleString -match $AfterExpression)
                {
                }
                else
                {
                    $NotFoundError += "The AfterExpression '$AfterExpression' was not found in the string."
                }
            }
            if ($BeforeExpression)
            {
                $SingleMatch = $SingleMatch + $BeforeExpression
                if ($SingleString -match $BeforeExpression)
                {
                }
                else
                {
                    $NotFoundError += "The BeforeExpression '$BeforeExpression' was not found in the string."
                }
            }
            $LineMatch = [regex]::Match($SingleString, $SingleMatch)
            if ($LineMatch.Success)
            {
                $TextToReturn = @("$($LineMatch.Groups[1].Value)")
            }
            else
            {
                if ($FailIfNotFound)
                {
                    if ($AfterExpression)
                    {
                        throw "Failed to find text in file.`n$($NotFoundError -join "`n")"
                    }
                }
            }
        }

        if ($null -ne $TextToReturn)
        {
            if ($AsString)
            {
                return [String]$TextToReturn
            }
            else
            {
                return Write-Output $TextToReturn -NoEnumerate
            }
        }
        else
        {
            return $null
        }
    }
}

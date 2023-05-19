function Search-FileContent
{
    [CmdletBinding()]
    param
    (
        # The path to the file to read
        [Parameter(Mandatory = $true)]
        [string]
        $FilePath,

        # The header/beginning/first line that indicates the block of text you want to return.
        [Parameter(Mandatory = $true)]
        [string]
        $StartStringPattern,

        # Where to stop searching
        [Parameter(Mandatory = $false)]
        [string]
        $StopStringPattern,

        # Returns a string instead of an array
        [Parameter(Mandatory = $false)]
        [switch]
        $AsString
    )
    
    begin
    {
        
    }
    
    process
    {
        try
        {
            $FileContentArray = Get-Content $FilePath -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to read file '$FilePath'.`n$($_.Exception.Message)"
        }

        $LineCount = 0
        $StartStringLine = $null
        $StopStringLine = $null
        $StartOffset = 1
        $StopOffset = -1
        # If there's not stop string pattern we assume the user wants to get the entire rest of the file, so we go until the last line
        if (!$StopStringPattern)
        {
            Write-Debug 'No stop string provided, using end of file'
            $StopStringLine = $FileContentArray.Count
            $StopOffset = 0
        }

        $FileContentArray | ForEach-Object {
            $Line = $_.Trim()
            $LineMatch = $null
            Write-Debug "Line: $LineCount`nContents:$Line"
            if (-not $StartStringLine)
            {
                $LineMatch = [regex]::Match($Line, $StartStringPattern)
                if ($LineMatch.Success)
                {
                    Write-Verbose "Found match to '$StartStringPattern' on line $LineCount"
                    $StartStringLine = $LineCount
                }
            }
            if ($StopStringPattern)
            {
                if (-not $StopStringLine)
                {
                    $LineMatch = [regex]::Match($Line, $StopStringPattern)
                    if ($LineMatch.Success)
                    {
                        Write-Verbose "Found match to '$StopStringPattern' on line $LineCount"
                        $StopStringLine = $LineCount
                    }
                }
            }
            $LineCount++
        }

        if (-not $StartStringLine)
        {
            throw "Failed to find '$StartStringPattern' in file at '$FilePath'."
        }
        if ($StopStringPattern)
        {
            if (-not $StopStringLine)
            {
                throw "Failed to find '$StopStringPattern' in file at '$FilePath'."
            }
        }
        # We want to get the line after the starting string
        $TextBlockStartLine = $StartStringLine + $StartOffset
        # And either the line before the stop string or the last line of the file depending on what we're doing
        $TextBlockStopLine = $StopStringLine + $StopOffset

        try
        {
            $TextToReturn = $FileContentArray[$TextBlockStartLine..$TextBlockStopLine]
            if (!$TextToReturn)
            {
                Write-Error 'Failed to get text to return.'
            }
        }
        catch
        {
            throw "Failed to extract text.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($TextToReturn)
        {
            if ($AsString)
            {
                return [String] $TextToReturn
            }
            else
            {
                return $TextToReturn
            }
        }
    }
}
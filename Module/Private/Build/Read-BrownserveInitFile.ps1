function Read-BrownserveInitFile
{
    [CmdletBinding()]
    param (
        # The path to the init file
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $InitFilePath
    )
    
    # Import the _init files content as an array (so we can read line-by-line)
    try
    {
        $InitContent = Get-Content $InitFilePath
    }
    catch
    {
        throw "Failed to import _init file content from $InitFilePath.`n$($_.Exception.Message)"
    }

    # The regex for matching our opening and closing lines
    $CustomCodeOpener = "\#\#\# Start user defined _init steps"
    $CustomCodeClosing = "\#\#\# End user defined _init steps"

    # Set up our special variables for counting lines
    $LineCount = 0
    $CustomCodeStart = $null
    $CustomCodeEnd = $null

    # Start reading through the _init script line by line...
    $InitContent | ForEach-Object {
        $Line = $_.Trim()
        # If we haven't already found our custom code opening block then see if this line matches it
        if (-not $CustomCodeStart)
        {
            $RegexMatch = [regex]::Match($Line, $CustomCodeOpener)
            if ($RegexMatch.Success)
            {
                # Our custom code will start on the next line _after_ this one
                $CustomCodeStart = $LineCount + 1
                Write-Verbose "User defined _init content starts on line $CustomCodeStart"
            }
        }
        if (-not $CustomCodeEnd)
        {
            $RegexMatch = [regex]::Match($Line, $CustomCodeClosing)
            if ($RegexMatch.Success)
            {
                # Our custom code will end on the next line _before_ this one
                $CustomCodeEnd = $LineCount - 1
                Write-Verbose "User defined _init content ends on line $CustomCodeEnd"
            }
        }
        
        # Increment our line counter
        $LineCount ++
    }

    # If we've actually found something then return it
    if ($CustomCodeStart -and $CustomCodeEnd)
    {
        # Extract those lines from the array
        $CustomCode = $InitContent[$CustomCodeStart..$CustomCodeEnd]
        # Only return something if we have something to return
        if ($CustomCode)
        {
            # This covers cases where people have accidentally deleted the line in the in-between
            if (-not ($CustomCode -match $CustomCodeOpener))
            {
                $Return = [pscustomobject]@{
                    CustomCode = $CustomCode
                }
                Return $Return
            }
        }
    }
    # Otherwise raise an error
    else
    {
        throw "Unable to find 'user defined _init steps' block in $InitFilePath."
    }
}
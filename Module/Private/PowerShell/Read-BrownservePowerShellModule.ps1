function Read-BrownservePowerShellModule
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $ModulePath
    )
    $Return = @{}
    # Import the module content as an array (so we can read line-by-line)
    try
    {
        $ModuleContent = Get-Content $ModulePath
    }
    catch
    {
        throw "Failed to import module file content from '$ModulePath'.`n$($_.Exception.Message)"
    }

    # The regex for matching the description block
    $DescriptionOpener = '\.SYNOPSIS'
    $DescriptionCloser = '#>'

    # The regex for matching our opening and closing lines
    $CustomCodeOpener = '\#\#\# Start user defined module steps'
    $CustomCodeClosing = '\#\#\# End user defined module steps'

    # Set up our special variables for counting lines
    $CustomLineCount = 0
    $DescLineCount = 0
    $CustomCodeStart = $null
    $CustomCodeEnd = $null
    $DescriptionStart = $null
    $DescriptionEnd = $null

    # First see if we can find the description (it may not be present)
    $ModuleContent | ForEach-Object {
        $Line = $_.Trim()
        # Start by looking for the opening text
        if (-not $DescriptionStart)
        {
            $RegexMatch = [regex]::Match($Line, $DescriptionOpener)
            if ($RegexMatch.Success)
            {
                # Our custom code will start on the next line _after_ this one
                $DescriptionStart = $DescLineCount + 1
                Write-Verbose "Module description starts on line $DescriptionStart"
            }
        }
        if (-not $DescriptionEnd)
        {
            $RegexMatch = [regex]::Match($Line, $DescriptionCloser)
            if ($RegexMatch.Success)
            {
                # Our custom code will end on the next line _before_ this one
                $DescriptionEnd = $DescLineCount - 1
                Write-Verbose "User defined module content ends on line $DescriptionEnd"
            }
        }
        
        # Increment our line counter
        $DescLineCount ++
    }

    # Start reading through the _init script line by line...
    $ModuleContent | ForEach-Object {
        $Line = $_.Trim()
        # If we haven't already found our custom code opening block then see if this line matches it
        if (-not $CustomCodeStart)
        {
            $RegexMatch = [regex]::Match($Line, $CustomCodeOpener)
            if ($RegexMatch.Success)
            {
                # Our custom code will start on the next line _after_ this one
                $CustomCodeStart = $CustomLineCount + 1
                Write-Verbose "User defined module content starts on line $CustomCodeStart"
            }
        }
        if (-not $CustomCodeEnd)
        {
            $RegexMatch = [regex]::Match($Line, $CustomCodeClosing)
            if ($RegexMatch.Success)
            {
                # Our custom code will end on the next line _before_ this one
                $CustomCodeEnd = $CustomLineCount - 1
                Write-Verbose "User defined module content ends on line $CustomCodeEnd"
            }
        }
        
        # Increment our line counter
        $CustomLineCount ++
    }

    # Add the returned customisations to the return object
    if ($CustomCodeStart -and $CustomCodeEnd)
    {
        # Extract those lines from the array
        $CustomCode = $ModuleContent[$CustomCodeStart..$CustomCodeEnd]
        # Only return something if we have something to return
        if ($CustomCode)
        {
            # This covers cases where people have accidentally deleted the line in the in-between
            if (-not ($CustomCode -match $CustomCodeOpener))
            {
                $Return.Add('CustomCode', $CustomCode)
            }
        }
    }
    # Otherwise raise an error
    else
    {
        throw "Unable to find user defined module content block in $ModulePath."
    }

    # If we've actually found the description then return it too
    if ($DescriptionStart -and $DescriptionEnd)
    {
        # Extract those lines from the array
        $Description = $ModuleContent[$DescriptionStart..$DescriptionEnd]
        # Only return something if we have something to return
        if ($Description)
        {
            $Return.Add('Description', $Description)
        }
    }
    # Don't return an error for descriptions, they are optional

    if ($Return -ne @{})
    {
        Return [pscustomobject]$Return
    }
}
function Get-Response
{
    [CmdletBinding()]
    param
    (
        # The prompt to post on screen
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $Prompt,

        # The type of value to return
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        [ValidateSet('string', 'bool', 'array')]
        $ResponseType,

        # Make the response mandatory (applies to string and arrays only)
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $Mandatory
    )
    # I've seen some weirdness where $Response can end up hanging around so set it to $null every time this cmdlet is called.
    $Response = $null
    switch ($ResponseType)
    {
        'bool'
        {
            # Booleans are always mandatory by their very nature 
            while (!$Response)
            {
                $Response = Read-Host "$Prompt [y]es/[n]o"
                switch ($Response.ToLower())
                {
                    { ($_ -eq 'y') -or ($_ -eq 'yes') }
                    {
                        Return $true
                    }
                    { ($_ -eq 'n') -or ($_ -eq 'no') }
                    {
                        Return $false
                    }
                    Default
                    {
                        Write-Host "Invalid response '$Response'" -ForegroundColor red
                        Clear-Variable 'Response'
                    }
                }
            }    
        }
        'string'
        {
            # If the string is mandatory then keep prompting until we get a valid response
            if ($Mandatory)
            {
                While (!$Response)
                {
                    $Response = Read-Host $Prompt
                }
            }
            # If not then allow us to skip
            else
            {
                $Prompt = $Prompt + " (Optional - press enter to skip)"
            }
            # Only return an object if we have one
            if ($Response)
            {
                Return [string]$Response
            }
        }
        'array'
        {
            # If the array is mandatory then keep prompting until we get a value
            if ($Mandatory)
            {
                While (!$Response)
                {
                    $Response = Read-Host "$Prompt [if specifying more than one separate with a comma]"
                }
            }
            # Otherwise allow the user to skip by hitting enter
            else
            {
                $Response = Read-Host "$Prompt [if specifying more than one separate with a comma] (Optional - press enter to skip)"
            }
            # Only return an object if we have one
            if ($Response)
            {
                $Array = $Response -split ","
                Return $Array
            }
        }
    }
}
function New-BlockComment
{
    [CmdletBinding()]
    param
    (
        # The text to comment
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]
        $InputObject,

        # The comment character to use
        [Parameter(
            Mandatory = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $CommentCharacter = '#'
    )
    
    begin
    {
        
    }
    
    process
    {
        $Return = @()
        $InputObject | ForEach-Object {
            if ($_ -match '^\s*$')
            {
                $Return += "$_`n"
            }
            else
            {
                $Return += "$CommentCharacter $_`n"
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
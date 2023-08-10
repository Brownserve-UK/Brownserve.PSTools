function ConvertTo-BlockComment
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
        $Return = @()
    }
    
    process
    {
        $InputObject | ForEach-Object {
            if ($_.StartsWith("$CommentCharacter"))
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
            return ($Return | Out-String -NoNewline)
        }
        else
        {
            return $null
        }
    }
}
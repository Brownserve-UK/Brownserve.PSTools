function Assert-Command
{
    [CmdletBinding()]
    param
    (
        # The command(s) to test
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]
        $Command
    )
    
    begin
    {
        $CommandNotFound = @()
    }
    
    process
    {
        $Command | ForEach-Object {
            $Check = $null
            $Check = Get-Command $_ -ErrorAction 'SilentlyContinue'
            if (!$Check)
            {
                $CommandNotFound += $_
            }
        }
    }
    
    end
    {
        if ($CommandNotFound.Count -gt 0)
        {
            throw "The following commands are not available on the path:`n$($CommandNotFound -join "`n")"
        }
    }
}
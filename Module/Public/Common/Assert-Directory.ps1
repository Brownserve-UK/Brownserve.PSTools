function Assert-Directory
{
    [CmdletBinding()]
    param
    (
        # The path to check
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [string]
        $Path
    )
    
    begin
    {
        
    }
    
    process
    {
        try
        {
            $PathDetails = Get-Item $Path -Force -ErrorAction Stop
            if (!$PathDetails.PSIsContainer)
            {
                Write-Error 'Path is not a directory' -ErrorAction Stop
            }
        }
        catch
        {
            throw "Path '$Path' does not exist or is not a valid directory.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}
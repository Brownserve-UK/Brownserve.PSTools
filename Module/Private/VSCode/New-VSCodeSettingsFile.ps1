function New-VSCodeSettingsFile
{
    [CmdletBinding()]
    param
    (
        # Any custom settings to be used
        [Parameter(Mandatory = $false)]
        [psobject]
        $Settings
    )
    
    begin
    {
        
    }
    
    process
    {
        try
        {
            if ($Settings)
            {
            
                $JSON = $Settings | ConvertTo-Json
            
            }
            else
            {
                $JSON = @{} | ConvertTo-Json
            }
        }
        catch
        {
            throw 'Failed to create settings JSON'
        }
    }
    end
    {
        if ($JSON)
        {
            return $JSON
        }
    }
}
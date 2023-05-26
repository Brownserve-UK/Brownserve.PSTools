function Read-ConfigurationFromFile
{
    [CmdletBinding()]
    param
    (
        # The path to the config to read
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $ConfigurationFile,

        # Return as a hashtable instead of object
        [Parameter(Mandatory = $false)]
        [switch]
        $AsHashtable
    )
    
    begin
    {
        
    }
    
    process
    {
        if (($ConfigurationFile | Split-Path -Leaf) -notmatch '\.json$|\.jsonc$')
        {
            throw "$ConfigurationFile must be a JSON file"
        }
        try
        {
            $ConvertParams = @{
                Depth = 999
                ErrorAction = 'Stop'
            }
            if ($AsHashtable)
            {
                $ConvertParams.Add('AsHashtable',$true)
            }
            $Config = Get-Content `
                -Path $ConfigurationFile `
                -Raw `
                -ErrorAction 'Stop' | ConvertFrom-Json @ConvertParams
        }
        catch
        {
            throw "Failed to read configuration file '$ConfigurationFile'.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($Config)
        {
            return $Config
        }
        else
        {
            return $null
        }
    }
}
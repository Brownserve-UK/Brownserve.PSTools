function Invoke-ConvertToYaml
{
    [CmdletBinding()]
    param
    (
        # The thing to be converted
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [System.Object]
        $InputObject,

        # Any options to be passed to ConvertTo-YAML
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [hashtable]
        $Parameters
    )
    
    begin
    {
        
    }
    
    process
    {
        # First import the powershell-yaml module, if the cmdlet returns something then we must unload the module at the end
        $LoadedModule = Import-PowerShellYAMLModule -ErrorAction 'Stop'

        try
        {
            $Return = ConvertTo-Yaml -Data $InputObject @Parameters -ErrorAction 'Stop'
        }
        catch
        {
            throw "`n$($_.Exception.Message)"
        }
        finally
        {
            if($LoadedModule)
            {
                Write-Verbose "Unloading powershell-yaml module"
                Remove-Module 'powershell-yaml' -Force -ErrorAction SilentlyContinue -Verbose:$false
            }
        }
    }
    
    end
    {
        if ($Return)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}
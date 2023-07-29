function Invoke-ConvertFromYaml
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
        [string]
        $InputObject,

        # Any options to be passed to ConvertFrom-YAML
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
            # Seems like splatting "$null" causes weirdness, so only splat if we have params
            if ($null -ne $Parameters)
            {
                $Return = ConvertFrom-YAML -yaml $InputObject @Parameters -ErrorAction 'Stop'
            }
            else
            {
                $Return = ConvertFrom-YAML -yaml $InputObject -ErrorAction 'Stop'
            }
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
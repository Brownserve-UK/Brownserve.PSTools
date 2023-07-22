function Import-PowerShellYAMLModule
{
    [CmdletBinding()]
    param
    (
        
    )
    
    begin
    {
        <#
            Check the current list of modules to make sure we don't have PlatyPS loaded, if we do then bomb out now.
            Also check to see if we already have PowerShell-YAML loaded, if we do we'll want to keep it loaded so as not to mess with the users environment!
        #>
        $LoadedModules = Get-Module
        if ($LoadedModules.Name -contains 'PlatyPS')
        {
            throw "Currently the PlatyPS and PowerShell-YAML modules cannot be loaded at the same time due to an assembly incompatibility.`nSee https://github.com/PowerShell/platyPS/issues/592 for more information"
        }
        $PreLoadedPowerShellYAML = $LoadedModules | Where-Object { $_.Name -eq 'powershell-yaml' }
    }
    
    process
    {
        try
        {
            # If it's already loaded then don't overwrite whatever the user has loaded!
            if (!$PreLoadedPowerShellYAML)
            {
                # First see if the special Brownserve variable is set, if so attempt to download the version from the repo.
                if ($Global:BrownserveRepoPowerShellYAMLPath)
                {
                    Write-Verbose 'Loading local version of PowerShell-YAML'
                    Import-Module $Global:BrownserveRepoPowerShellYAMLPath `
                        -Force `
                        -ErrorAction 'Stop' `
                        -Verbose:$false
                }
                # Otherwise attempt to load any version installed on the system
                else
                {
                    Write-Verbose 'Loading system version of PowerShell-YAML'
                    Import-Module 'powershell-yaml' `
                        -Force `
                        -ErrorAction 'Stop' `
                        -Verbose:$false
                }
            }
        }
        catch
        {
            $ErrorMessage = 'Failed to load powershell-yaml module.'
            if (!$Global:BrownserveRepoPlatyPSPath)
            {
                $ErrorMessage += "`nThe '`$Global:BrownserveRepoPowerShellYAMLPath' variable has not been set and PowerShell failed to load any versions installed locally."
            }
            throw "$ErrorMessage.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($PreLoadedPowerShellYAML)
        {
            return $PreLoadedPowerShellYAML
        }
        else
        {
            return $null
        }
    }
}
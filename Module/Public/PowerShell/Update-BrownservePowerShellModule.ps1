function Update-BrownservePowerShellModule
{
    [CmdletBinding()]
    param
    (
        # The path where the PowerShell module should be created
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # An optional description for the module
        [Parameter(Mandatory = $false)]
        [string]
        $Description,

        # Any custom code to include when creating the module
        [Parameter(Mandatory = $false)]
        [Alias('Customizations')]
        [string]
        $Customisations,

        # Forces overwriting of files
        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )
    
    begin
    {
        # First extract any custom content from the module so it can be preserved
        try
        {
            $CurrentModuleContent = Read-BrownservePowerShellModule -ModulePath $Path -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to interpolate module at '$Path' are you sure it's a Brownserve PowerShell module?`n$($_.Exception.Message)"
        }
    }
    
    process
    {
        if ($CurrentModuleContent.Description)
        {
            if ($Description)
            {
                if ($Force)
                {
                    $ModuleDescription = $Description
                }
                else
                {
                    throw "Module at '$Path' already has a description, to overwrite please use the -Force parameter."
                }
            }
            else
            {
                $ModuleDescription = ($CurrentModuleContent.Description | Out-String).Trim()
            }
        }

        if ($CurrentModuleContent.CustomCode)
        {
            if ($Customisations)
            {
                if ($Force)
                {
                    $ModuleCustomisations = $Customisations
                }
                else
                {
                    throw "Module at '$Path' already has customisations, to overwrite please use the -Force parameter."
                }
            }
            else
            {
                $ModuleCustomisations = ($CurrentModuleContent.CustomCode | Out-String).Trim()
            }
        }

        $Params = @{}
        if ($ModuleDescription)
        {
            $Params.Add('Description', $ModuleDescription)
        }
        if ($ModuleCustomisations)
        {
            $Params.Add('Customisations', $ModuleCustomisations)
        }
        try
        {
            $ModuleTemplate = New-BrownservePoShModuleFromTemplate @Params -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to build module template.`n$($_.Exception.Message)"
        }

        try
        {
            Set-Content -Path $Path -Value $ModuleTemplate -Force:$Force
        }
        catch
        {
            throw "Failed to update module content at '$Path'.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}
function New-BrownservePowerShellModule
{
    [CmdletBinding()]
    param
    (
        # The path where the PowerShell module should be created
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # The name of the module to be created
        [Parameter(Mandatory = $true)]
        [Alias('name')]
        [string]
        $ModuleName,

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
        if ($ModuleName -notmatch '\.psm1$')
        {
            $ModuleName = $ModuleName + '.psm1'
        }
        try
        {
            $ModulePath = Join-Path $Path $ModuleName
            Test-Directory -Path $Path -ErrorAction 'Stop'
            if (Test-Path $ModulePath)
            {
                if (!$Force)
                {
                    throw "Module at '$ModulePath' already exists. Use 'Update-BrownservePowerShellModule' to update your module or '-Force' to overwrite"
                }
                else
                {
                    Write-Warning 'current module will be overwritten entirely.'
                }
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    
    process
    {
        $Params = @{}
        if ($Description)
        {
            $Params.Add('Description', $Description)
        }
        if ($Customisations)
        {
            $Params.Add('Customisations', $Customisations)
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
            New-Item $ModulePath -Value $ModuleTemplate -ItemType File -ErrorAction 'Stop' -Force:$Force
        }
        catch
        {
            throw "Failed to create new module.`n$($_.Exception.Message)"
        }

        # Do we want to create the Public/Private paths?
    }
    
    end
    {
        
    }
}
function New-BrownservePowerShellModule
{
    [CmdletBinding()]
    param
    (
        # The name of the module to be created
        [Parameter(
            Mandatory = $true,
            Position  = 0
        )]
        [Alias('name')]
        [string]
        $ModuleName,

        # The path where the PowerShell module should be created
        [Parameter(
            Mandatory = $false,
            Position  = 1
        )]
        [string]
        $Path = $PWD,

        # A description for the module
        [Parameter(
            Mandatory = $false,
            Position  = 2
        )]
        [string]
        $Description,

        # Any custom code to include when creating the module
        [Parameter(Mandatory = $false)]
        [Alias('Customizations')]
        [string]
        $Customisations,

        # The required version of PowerShell for the module
        [Parameter(Mandatory = $false)]
        [string]
        $RequirePowerShellVersion = '6.0',

        # If set will require the Brownserve.PSTools module to be installed
        [Parameter(Mandatory = $false)]
        [bool]
        $RequireBrownservePSTools = $true,

        # If set will include the BrownserveCmdlets logic in the module
        [Parameter(Mandatory = $false)]
        [bool]
        $IncludeBrownserveCmdletsLogic = $true,

        # Forces overwriting of files
        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )
    begin
    {
    }
    process
    {
        if ($ModuleName -match '\.psm1$')
        {
            $ModuleName = $ModuleName -replace '\.psm1', ''
        }
        $ModulePath = Join-Path $Path "$ModuleName.psm1"
        try
        {
            Assert-Directory -Path $Path -ErrorAction 'Stop'
            if (Test-Path $ModulePath)
            {
                if (!$Force)
                {
                    throw "Module at '$ModulePath' already exists. Use 'Update-BrownservePowerShellModule' to update your module or '-Force' to overwrite"
                }
                else
                {
                    Write-Warning "Module '$ModulePath' will be overwritten entirely."
                }
            }
        }
        catch
        {
            throw $_.Exception.Message
        }
        $ModuleParams = @{
            RequireBrownservePSTools      = $RequireBrownservePSTools
            IncludeBrownserveCmdletsLogic = $IncludeBrownserveCmdletsLogic
        }
        if ($Description)
        {
            $ModuleParams.Add('Description', $Description)
        }
        if ($Customisations)
        {
            $ModuleParams.Add('Customisations', $Customisations)
        }
        if ($RequirePowerShellVersion)
        {
            $ModuleParams.Add('RequirePowerShellVersion', $RequirePowerShellVersion)
        }
        try
        {
            $ModuleTemplate = New-BrownservePoShModuleFromTemplate @ModuleParams -ErrorAction 'Stop'
            $ModuleContent = $ModuleTemplate | Format-BrownserveContent -ErrorAction 'Stop'
            Write-Debug "Module template:`n$($ModuleTemplate.Content)"
        }
        catch
        {
            throw "Failed to build module template.`n$($_.Exception.Message)"
        }

        try
        {
            New-Item $ModulePath -ItemType File -ErrorAction 'Stop' -Force:$Force
            $ModuleContent | Set-BrownserveContent -Path $ModulePath -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to create new module.`n$($_.Exception.Message)"
        }

        try
        {
            # NEVER try to overwrite the public/private directories if they exist, they may have cmdlets in them
            $PublicPath = (Join-Path $Path 'Public')
            if (!(Test-Path $PublicPath))
            {
                New-Item $PublicPath -ItemType Directory -ErrorAction 'Stop'
            }
            $PrivatePath = (Join-Path $Path 'Private')
            if (!(Test-Path $PrivatePath))
            {
                New-Item $PrivatePath -ItemType Directory -ErrorAction 'Stop'
            }
        }
        catch
        {
            throw "Failed to create module public/private directories.`n$($_.Exception.Message)"
        }
    }
    end
    {
    }
}

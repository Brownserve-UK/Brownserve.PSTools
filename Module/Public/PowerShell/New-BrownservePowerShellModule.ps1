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

        # The GUID for the module
        [Parameter(Mandatory = $false)]
        [guid]
        $ModuleGUID = (New-Guid),

        # The tags for this module
        [Parameter(Mandatory = $false)]
        [string[]]
        $ModuleTags = @('Brownserve-UK'),

        # A description for the module
        [Parameter(Mandatory = $true)]
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
        if ($ModuleName -match '\.psm1$')
        {
            $ModuleName = $ModuleName -replace '\.psm1',''
        }
        try
        {
            $ModulePath = Join-Path $Path "$ModuleName.psm1"
            $ModuleInfoPath = Join-Path $Path 'ModuleInfo.json'
            Assert-Directory -Path $Path -ErrorAction 'Stop'
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
        # Create the JSON we'll use to store the module info
        $ModuleInfo = [ordered]@{
            name = $ModuleName
            description = $Description
            guid = $ModuleGUID
            tags = $ModuleTags
        } | ConvertTo-Json
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
        try
        {
            New-Item $ModuleInfoPath -Value $ModuleInfo -ItemType File -ErrorAction 'Stop' -Force:$Force
        }
        catch
        {
            throw "Failed to create the ModuleInfo file.`n$($_.Exception.Message)"
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
            throw "Failed to created module public/private directories.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        return [BrownservePowerShellModule]@{
            Name = $ModuleName
            Description = $Description
            GUID = $ModuleGUID
            Tags = $ModuleTags
        }
    }
}
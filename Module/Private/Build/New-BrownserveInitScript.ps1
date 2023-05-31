function New-BrownserveInitScript
{
    [CmdletBinding()]
    param
    (
        # The permanent paths (i.e. those that should always exists)
        [Parameter(
            Mandatory = $true
        )]
        [InitPath[]]
        $PermanentPaths,

        # The ephemeral paths
        [Parameter(
            Mandatory = $true
        )]
        [InitPath[]]
        $EphemeralPaths,

        # If passed will create a block that attempts to load any local/custom PowerShell modules in the code directory
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'LocalModule'
        )]
        [switch]
        $IncludeCodeDirectoryModuleLoader,

        # If passed will create a block that loads a single module from the "Module" directory
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Module'
        )]
        [switch]
        $IncludeModuleLoader,

        # If passed will include our custom powershell-yaml loader
        [Parameter(Mandatory = $false)]
        [switch]
        $IncludePowerShellYaml,

        # If passed will include our custom PlatyPS loader
        [Parameter(Mandatory = $false)]
        [switch]
        $IncludePlatyPS,

        # If passed will include our Invoke-Build/Pester loader
        [Parameter(Mandatory = $false)]
        [switch]
        $IncludeBuildTestTools,

        # Any custom init steps
        [Parameter(
            Mandatory = $false
        )]
        [string]
        $CustomInitSteps
    )
    
    begin
    {
        # Import the template
        try
        {
            $InitTemplate = Get-Content (Join-Path $PSScriptRoot 'templates' init.ps1.template) -Raw
        }
        catch
        {
            throw "Failed to import InitTemplate.`n$($_.Exception.Message)"
        }    
    }
    
    process
    {
        # We'll go over each permanent path and create an entry in the _init file that will resolve the path
        # to it's actual location
        $PermanentPathText = ''
        $PermanentPaths | ForEach-Object {
            # If we have a description we need to have that appear first
            if ($_.Description)
            {
                $PermanentPathText = $PermanentPathText + "# $($_.Description)`n"
            }
            # If we've got child paths we'll have to do some really fancy interpolation
            if ($_.ChildPaths)
            {
                $Path = "-ChildPath '$($_.Path)' -AdditionalChildPath '$($_.ChildPaths | Join-String -Separator "','")'" 
            }
            else
            {
                $Path = "-ChildPath '$($_.Path)'"
            }
            $PermanentPathText = $PermanentPathText + @"
`$Global:$($_.VariableName) = Join-Path `$global:BrownserveRepoRootDirectory $Path | Convert-Path`n
"@
        }
        $InitTemplate = $InitTemplate.Replace('###PERMANENT_PATHS###', $PermanentPathText)

        # For our ephemeral paths we first need to define them as standalone variables, so we can create them
        # if they don't already exist
        $EphemeralPathText = ",`n"
        $EphemeralPaths | ForEach-Object -Process {
            # If we've got child paths we'll have to do some really fancy interpolation
            if ($_.ChildPaths)
            {
                $Path = "-ChildPath '$($_.Path)' -AdditionalChildPath '$($_.ChildPaths | Join-String -Separator "','")'" 
            }
            else
            {
                $Path = "-ChildPath '$($_.Path)'"
            }
            $EphemeralPathText = $EphemeralPathText + @"
    (`$$($_.VariableName) = Join-Path -Path `$global:BrownserveRepoRootDirectory $Path)
"@
            # We are building an array in the template
            # if this is the last line of the array then we don't want to add a comma!
            if ($_ -eq $EphemeralPaths[-1])
            {
                $EphemeralPathText = $EphemeralPathText + "`n"
            }
            else
            {
                $EphemeralPathText = $EphemeralPathText + ",`n"
            }
        }
        $InitTemplate = $InitTemplate.Replace('###EPHEMERAL_PATHS###', $EphemeralPathText)

        # Now we can create our global variables that reference their proper paths
        $EphemeralPathVariableText = "`n"
        $EphemeralPaths | ForEach-Object {
            # If we have a description we need to have that appear first
            if ($_.Description)
            {
                $EphemeralPathVariableText = $EphemeralPathVariableText + "# $($_.Description)`n"
            }
            $EphemeralPathVariableText = $EphemeralPathVariableText + @"
`$global:$($_.VariableName) = `$$($_.VariableName) | Convert-Path`n
"@
        }
        $InitTemplate = $InitTemplate.Replace('###EPHEMERAL_PATH_VARIABLES###', $EphemeralPathVariableText)

        $ModuleText = ''
        # Here we set up our custom module loader for loading any Powershell modules we may have created in a given repo
        if ($IncludeCodeDirectoryModuleLoader)
        {
            if ($PermanentPaths.VariableName -notcontains 'BrownserveRepoCodeDirectory')
            {
                throw "Cannot use '-IncludeCodeDirectoryModuleLoader' when 'BrownserveRepoCodeDirectory' has not been specified"
            }
            $ModuleText = @'

# Find and load any local PowerShell modules we've written for this repo in the "code" directory
try
{
    Write-Verbose "Checking '$($global:BrownserveRepoCodeDirectory)' for any PowerShell modules to load'
    Get-ChildItem $global:BrownserveRepoCodeDirectory -Filter '*.psm1' -Recurse | Foreach-Object {
        Import-Module $_ -Force -Verbose:$false
    }
}
catch
{
    throw "Failed to import local modules.`n$($_.Exception.Message)"
}

'@
        }
        # Alternatively the repo may contain a single module, in which case we load that
        if ($IncludeModuleLoader)
        {
            if ($PermanentPaths.VariableName -notcontains 'BrownserveModuleDirectory')
            {
                throw "Cannot use 'IncludeModuleLoader' when 'BrownserveModuleDirectory' has not been specified"
            }
            $ModuleText = @'

# Load the module from the "Module" directory
try
{
    Write-Verbose "Loading module from '$($Global:BrownserveModuleDirectory)'"
    Get-ChildItem $Global:BrownserveModuleDirectory -Filter '*.psm1' -Recurse | Foreach-Object {
        Import-Module $_ -Force -Verbose:$false
    }
}
catch
{
    throw "Failed to import module.`n$($_.Exception.Message)"
}

'@
        }
        # Add in any custom module loaders we're using
        $InitTemplate = $InitTemplate.Replace('###MODULE_LOADER###', $ModuleText)

        $CustomExternalTooling = ''

        if ($IncludePlatyPS)
        {
            $CustomExternalTooling += @"
<#
    Some cmdlets make use of the platyPS module so ensure it is available
    Unfortunately due to https://github.com/PowerShell/platyPS/issues/592 we cannot load this at the same time as powershell-yaml.
    This should be fixed in a later v2 release but v2 is incredibly buggy at the moment and often fails with unhelpful errors.
    So we download the module and set a special variable to its path.
#>
try
{
    Write-Verbose 'Downloading platyPS module'
    Save-Module 'platyPS' -Repository PSGallery -Path `$Global:BrownserveRepoNugetPackagesDirectory -ErrorAction 'Stop'
    `$PlatyPSLocation = Join Path `$Global:BrownserveRepoPaketFilesDirectory -ChildPath PowerShell -AdditionalChildPath platyPS
    # DON'T import the module, set a well known variable that we can use later on.
    `$Global:BrownserveRepoPlatyPSPath = Get-ChildItem (Join-Path `$Global:BrownserveRepoNugetPackagesDirectory -ChildPath 'platyPS') -Filter 'platyPS.psd1' -Recurse
    if (!`$Global:BrownserveRepoPlatyPSPath)
    {
        throw 'Failed to find downloaded PlatyPS'
    }
}
catch
{
    throw "Failed to download the platyPS module.``n`$(`$_.Exception.Message)"
}`n`n
"@
        }

        if ($IncludePowerShellYaml)
        {
            $CustomExternalTooling += @"
# Some cmdlets make use of the powershell-yaml module so ensure it is available, we don't auto-load it to avoid clashing with platyPS
try
{
    Write-Verbose 'Downloading powershell-yaml module'
    Save-Module 'powershell-yaml' -Repository PSGallery -Path `$Global:BrownserveRepoNugetPackagesDirectory -ErrorAction 'stop'
    `$Global:BrownserveRepoPowerShellYAMLPath = Get-ChildItem (Join-Path `$Global:BrownserveRepoNugetPackagesDirectory -ChildPath 'powershell-yaml') -Filter 'powershell-yaml.psd1' -Recurse
    if (!`$Global:BrownserveRepoPowerShellYAMLPath)
    {
        throw 'Failed to find powershell-yaml module after download'
    }
}
catch
{
    throw "Failed to download the powershell-yaml module.``n`$(`$_.Exception.Message)"
}`n`n
"@
        }

        

        if ($IncludeBuildTestTools)
        {
            $CustomExternalTooling += @"
# This repo makes use of Invoke-Build/Pester to run our builds so we need to import them.
try
{
    # Both modules should have been grabbed from nuget by paket, we simply need to import them
    Write-Verbose 'Importing Invoke-Build'
    Join-Path `$Global:BrownserveRepoNugetPackagesDirectory 'Invoke-Build' -AdditionalChildPath 'tools', 'InvokeBuild.psd1' | Import-Module -Force
    Write-Verbose 'Importing Pester'
    Join-Path `$Global:BrownserveRepoNugetPackagesDirectory 'Pester' -AdditionalChildPath 'tools', 'Pester.psd1' | Import-Module -Force
}
catch
{
    throw "Failed to import build/test modules.``n`$(`$_.Exception.Message)"
}`n`n
"@
        }

        # Add in any external tooling we may be using
        $InitTemplate = $InitTemplate.Replace('###EXTERNAL_TOOLING###', $CustomExternalTooling)
        # Finally we carry over any custom _init steps if the user has given them
        $InitTemplate = $InitTemplate.Replace('###CUSTOM_INIT_STEPS###', $CustomInitSteps)
    }   
    end
    {
        Return $InitTemplate
    }
}
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

        # Whether or not to include our custom PowerShell module loader
        [Parameter(
            Mandatory = $false
        )]
        [switch]
        $IncludeModuleLoader,

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
            $InitTemplate = Get-Content (Join-Path $PSScriptRoot init.ps1.template) -Raw
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
        $PermanentPathText = ""
        $PermanentPaths | ForEach-Object {
            # If we have a description we need to have that appear first
            if ($_.Description)
            {
                $PermanentPathText = $PermanentPathText + "# $($_.Description)`n"
            }
            # If we've got child paths we'll have to do some really fancy interpolation
            if ($_.ChildPaths)
            {
                $Path = "'$($_.Path)' " + $("'" + ($_.ChildPaths -join "','") + "'")
            }
            else
            {
                $Path = "'$($_.Path)'"
            }
            $PermanentPathText = $PermanentPathText + @"
`$Global:$($_.VariableName) = Join-Path `$global:RepoRootDirectory $Path | Convert-Path`n
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
                $Path = "'$($_.Path)' " + $("'" + ($_.ChildPaths -join "','") + "'")
            }
            else
            {
                $Path = "'$($_.Path)'"
            }
            $EphemeralPathText = $EphemeralPathText + @"
    (`$$($_.VariableName) = Join-Path `$global:RepoRootDirectory $Path)
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

        # Here we set up our custom module loader for loading any Powershell modules we may have created in a given repo
        if ($IncludeModuleLoader)
        {
            $ModuleText = @'

try
{
    Get-ChildItem $global:RepoCodeDirectory -Filter '*.psm1' | Foreach-Object {
        Import-Module $_ -Force -Verbose:$false
    }
}
catch
{
    throw "Failed to import custom modules.`n$($_.Exception.Message)"
}

'@
        }
        $InitTemplate = $InitTemplate.Replace('###CUSTOM_MODULE_LOADER###', $ModuleText)

        # Finally we carry over any custom _init steps if the user has given them
        $InitTemplate = $InitTemplate.Replace('###CUSTOM_INIT_STEPS###', $CustomInitSteps)
    }   
    end
    {
        Return $InitTemplate
    }
}
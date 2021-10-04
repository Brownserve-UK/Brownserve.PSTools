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
            $InitTemplate = Get-Content ./init.ps1.template -Raw
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
            $PermanentPathText = $PermanentPathText + @"
`$Global:$($_.VariableName) = Join-Path `$global:RepoRootDirectory '$($_.Path)' | Convert-Path`n
"@
        }
        $InitTemplate = $InitTemplate -replace '###PERMANENT_PATHS###', $PermanentPathText

        # For our ephemeral paths we first need to define them as standalone variables, so we can create them
        # if they don't already exist
        $EphemeralPathText = "`$EphemeralPaths = @(`n"
        $EphemeralPaths | ForEach-Object -Process {
            $EphemeralPathText = $EphemeralPathText + @"
    (`$$($_.VariableName) = Join-Path `$global:RepoRootDirectory '$($_.Path)')
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
        $EphemeralPathText = $EphemeralPathText + ")"
        $InitTemplate = $InitTemplate -replace '###EPHEMERAL_PATHS###', $EphemeralPathText

        # Now we can create our global variables that reference their proper paths
        $EphemeralPathVariableText = ""
        $EphemeralPaths | ForEach-Object {
            $EphemeralPathVariableText = $EphemeralPathVariableText + @"
`$global:$($_.VariableName) = `$$($_.VariableName) | Convert-Path`n
"@
        }
        $InitTemplate = $InitTemplate -replace '###EPHEMERAL_PATH_VARIABLES###', $EphemeralPathVariableText

        # Here we set up our custom module loader for loading any Powershell modules we may have created in a given repo
        if ($IncludeModuleLoader)
        {
            $ModuleText = @"
try
{
    Get-ChildItem `$global:RepoModuleDirectory -Filter '*.psm1' | Foreach-Object {
        Import-Module `$_ -Force -Verbose:`$false
    }
}
catch
{
    throw "Failed to import custom modules.``n`$(`$_.Exception.Message)
}
"@
        }
        $InitTemplate = $InitTemplate -replace '###CUSTOM_MODULE_LOADER###', $ModuleText

        # Finally we carry over any custom _init steps if the user has given them
        $InitTemplate = $InitTemplate -replace '###CUSTOM_INIT_STEPS###', $CustomInitSteps
    }   
    end
    {
        Return $InitTemplate
    }
}
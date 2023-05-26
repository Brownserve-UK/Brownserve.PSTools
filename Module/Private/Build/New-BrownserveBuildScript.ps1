function New-BrownserveBuildScript
{
    [CmdletBinding()]
    param
    (
        
    )
    
    begin
    {
        
    }
    
    process
    {
        # Import the template
        try
        {
            $ScriptTemplate = Get-Content (Join-Path $PSScriptRoot 'templates' psmodule_build_script.ps1.template) -Raw
        }
        catch
        {
            throw "Failed to import build script template.`n$($_.Exception.Message)"
        }

        # Right now our build script is completely static and has no customisations so we can just return it as is
    }
    
    end
    {
        Return $ScriptTemplate
    }
}
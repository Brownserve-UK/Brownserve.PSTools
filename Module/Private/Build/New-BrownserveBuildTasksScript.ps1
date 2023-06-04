function New-BrownserveBuildTasksScript
{
    [CmdletBinding()]
    param
    (
        
    )
    
    begin
    {
        # Import the template
        try
        {
            $ScriptTemplate = Get-Content (Join-Path $PSScriptRoot 'templates' psmodule_build_tasks.ps1.template) -Raw
        }
        catch
        {
            throw "Failed to import script template.`n$($_.Exception.Message)"
        }

        # As it stands we only have one static set of build tasks so we don't need to perform any transformations on it
    }
    
    process
    {
        return $ScriptTemplate
    }
    
    end
    {
        
    }
}
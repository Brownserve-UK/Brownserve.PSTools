function New-BrownservePoShModuleFromTemplate
{
    [CmdletBinding()]
    param
    (
        # An optional description for the module
        [Parameter(Mandatory = $false)]
        [string]
        $Description,

        # Any custom code to include when creating the module
        [Parameter(Mandatory = $false)]
        [Alias('Customizations')]
        [string]
        $Customisations
    )
    
    begin
    {
        # Import the template
        try
        {
            $ModuleTemplate = Get-Content (Join-Path $PSScriptRoot Module.template) -Raw
        }
        catch
        {
            throw "Failed to import Module template.`n$($_.Exception.Message)"
        } 
    }
    
    process
    {
        if ($Description)
        {
            $DescriptionHeader = @"
            <#
            .SYNOPSIS
                $Description
            #>`n
"@
            $ModuleContent = $DescriptionHeader + $ModuleTemplate
        }
        else
        {
            $ModuleContent = $ModuleTemplate
        }
        if ($Customisations)
        {
            $ModuleContent = $ModuleContent.Replace('###CUSTOMISATIONS###', $Customisations)
        }
        else
        {
            $ModuleContent = $ModuleContent.Replace('###CUSTOMISATIONS###', '')
        }
        $Return = $ModuleContent
    }
    
    end
    {
        if ($Return)
        {
            return $Return
        }
    }
}
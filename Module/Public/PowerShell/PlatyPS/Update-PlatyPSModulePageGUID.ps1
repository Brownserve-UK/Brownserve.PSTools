<#
.SYNOPSIS
    Updates the module GUID in the PlatyPS module page.
.DESCRIPTION
    The Update-MarkdownHelpModule cmdlet in the PlatyPS module doesn't support updating the module GUID in the module
    page.
    This cmdlet will check the module manifest for the GUID and update the module GUID in the module page.
#>
function Update-PlatyPSModulePageGUID
{
    [CmdletBinding()]
    param
    (
        # The GUID of the module
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [guid]
        $ModuleGUID,

        # The path to the module page
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModulePagePath
    )
    begin
    {
    }
    process
    {
        $ModulePageContent = Get-Content $ModulePagePath -ErrorAction 'Stop' -Raw
        if (!$ModulePageContent)
        {
            throw 'Module page content is empty'
        }
        $NewModuleGUID = $ModuleGUID.ToString()
        $NewModulePageContent = $ModulePageContent -replace 'Module Guid: ([\w|\d|-]*)', "Module Guid: $NewModuleGUID"

        try
        {
            Set-Content `
                -Path $ModulePagePath `
                -Value $NewModulePageContent `
                -NoNewline `
                -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to update module page GUID.`n$($_.Exception.Message)"
        }
    }
    end
    {
    }
}

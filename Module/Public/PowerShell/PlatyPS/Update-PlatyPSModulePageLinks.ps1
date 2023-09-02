<#
.SYNOPSIS
    Updates the links to cmdlet documentation in the PlatyPS module page.
.DESCRIPTION
    When PlatyPS creates a module page the links it creates assume that the cmdlet documentation is in the same directory
    as the module page.
    This cmdlet will update the links to point to the correct location.
    We may be able to remove the below once this issue is resolved: https://github.com/PowerShell/platyPS/issues/451
#>
function Update-PlatyPSModulePageLinks
{
    [CmdletBinding()]
    param
    (
        # The path to where the cmdlet documentation is stored
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $CmdletDocumentationPath,

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
        $ModulePageAdjustment = Split-Path $CmdletDocumentationPath -Leaf
        $NewModulePageContent = $ModulePageContent -replace '\(([\w|\d]*-[\w|\d]*.md)\)', "(./$ModulePageAdjustment/`$1)"

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
            throw "Failed to update module page links.`n$($_.Exception.Message)"
        }
    }
    end
    {
    }
}

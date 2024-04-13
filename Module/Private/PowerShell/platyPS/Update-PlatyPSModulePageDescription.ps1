<#
.SYNOPSIS
    Updates the PlatyPS module page module description field.
.DESCRIPTION
    The Update-MarkdownHelpModule cmdlet in the PlatyPS module doesn't support updating the module description in the module
    page.
    This cmdlet will set the module description in the module page to the description specified.
.#>
function Update-PlatyPSModulePageDescription
{
    [CmdletBinding()]
    param
    (
        # The description of the module
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleDescription,

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
        if ($ModulePageContent -imatch '## Description[\s\n]*{{ Fill in the Description }}')
        {
            # .Replace method doesn't work 🤷‍♀️ so use the -replace param instead.
            $NewModulePageContent = $ModulePageContent -Replace '## Description[\s\n]*{{ Fill in the Description }}', "## Description`r`n$ModuleDescription"
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
                throw "Failed to update module page description.`n$($_.Exception.Message)"
            }
        }
        else
        {
            Write-Verbose 'Module page description already set'
        }
    }
    end
    {
    }
}

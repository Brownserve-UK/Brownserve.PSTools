function New-BrownservePoShModuleFromTemplate
{
    [CmdletBinding()]
    param
    (
        # An optional description for the module
        [Parameter(Mandatory = $false)]
        [string[]]
        $Description,

        # Any custom code to include when creating the module
        [Parameter(Mandatory = $false)]
        [Alias('Customizations')]
        [string]
        $Customisations,

        # The version of PowerShell the module requires
        [Parameter(Mandatory = $false)]
        [string]
        $RequirePowerShellVersion,

        # If set will require the Brownserve.PSTools module to be installed
        [Parameter(Mandatory = $false)]
        [bool]
        $RequireBrownservePSTools = $true,

        # If set will include the BrownserveCmdlets logic in the module
        [Parameter(Mandatory = $false)]
        [bool]
        $IncludeBrownserveCmdletsLogic = $true
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
        $ModuleContent = $ModuleTemplate
        if ($Description)
        {
            # Description _might_ be a multi-line string so we need to format it correctly
            if ($Description -match "`n")
            {
                $Description = $Description -split "`n"
            }
            # Remove the last line if it's blank
            if ($Description[-1] -eq '')
            {
                $Description = $Description[0..($Description.Length - 2)]
            }
            $FormattedDescription = ".DESCRIPTION"
            foreach ($Line in $Description)
            {
                $Line = $Line.Trim()
                $FormattedDescription += "`n    $Line"
            }
            $ModuleContent = $ModuleContent.Replace('###DESCRIPTION###', $FormattedDescription)
        }
        else
        {
            $ModuleContent = $ModuleContent.Replace("###DESCRIPTION###`n", '')
        }
        if ($RequirePowerShellVersion)
        {
            $Requirements = "#Requires -Version $RequirePowerShellVersion`n"
        }
        if ($RequireBrownservePSTools)
        {
            if ($Requirements)
            {
                $Requirements += "#Requires -Module Brownserve.PSTools`n"
            }
            else
            {
                $Requirements = "#Requires -Module Brownserve.PSTools`n"
            }
        }
        if ($Requirements)
        {
            $ModuleContent = $ModuleContent.Replace('###REQUIREMENTS###', $Requirements)
        }
        else
        {
            $ModuleContent = $ModuleContent.Replace("###REQUIREMENTS###`n", '')
        }
        if ($Customisations)
        {
            $ModuleContent = $ModuleContent.Replace('###CUSTOMISATIONS###', $Customisations)
        }
        else
        {
            $ModuleContent = $ModuleContent.Replace('###CUSTOMISATIONS###', '')
        }
        if ($IncludeBrownserveCmdletsLogic)
        {
            $ModuleContent = $ModuleContent.Replace('###PUBLIC_CMDLET_ARRAY###', "`n`$PublicCmdlets = @()")
            $ModuleContent = $ModuleContent.Replace('###PUBLIC_CMDLET_HELP###', "`n                `$PublicCmdlets += Get-Help `$_.BaseName")
            $ModuleContent = $ModuleContent.Replace('###BROWNSERVE_CMDLETS###', @'
<#
    "BrownserveCmdlets" is a special variable that can be used to store the cmdlets that have been made available from this module (and indeed _all_ Brownserve modules).
    This allows us to output a summary of the cmdlets that are available in the module from things like repo _init scripts.
    Unfortunately just checking for the existence of the variable isn't enough as if it's blank PowerShell seems to treat it as null so we test for it being an array.
#>
if ($Global:BrownserveCmdlets -is 'System.Array')
{
    $Global:BrownserveCmdlets += @{
        Module  = "$($MyInvocation.MyCommand)"
        Cmdlets = $PublicCmdlets
    }
}
'@)
        }
        else
        {
            $ModuleContent = $ModuleContent.Replace("###PUBLIC_CMDLET_ARRAY###`n", '')
            $ModuleContent = $ModuleContent.Replace("###PUBLIC_CMDLET_HELP###`n", '')
            $ModuleContent = $ModuleContent.Replace("###BROWNSERVE_CMDLETS###`n", '')
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

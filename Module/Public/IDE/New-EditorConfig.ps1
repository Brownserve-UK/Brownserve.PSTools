<#
.SYNOPSIS
    Creates a new editorconfig configuration.
.DESCRIPTION
    This cmdlet will create a new editorconfig configuration without writing it to disk.
#>
function New-EditorConfig
{
    [CmdletBinding()]
    param
    (
        # Whether or not to include the root editorconfig file
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [bool]
        $IncludeRoot = $true,

        # The section to add to the editorconfig file
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [EditorConfigSection[]]
        $Section
    )
    begin
    {
        $Header = @"
# EditorConfig Helps Developers Define and Maintain Consistent Coding Styles Between Different Editors and IDEs.
# For more information about the file format, see http://EditorConfig.org.`n`n
"@
    }
    process
    {
        $Return = $Header
        if ($IncludeRoot -eq $true)
        {
            $Return += @"
# top-most EditorConfig file
root = true`n`n
"@
        }
        $Section | ForEach-Object {
            $Return += $_.ToString()
            if ($_ -ne $Section[-1])
            {
                $Return += "`n"
            }
        }
    }
    end
    {
        if ($Return -ne $Header)
        {
            Return $Return
        }
        else
        {
            return $null
        }
    }
}

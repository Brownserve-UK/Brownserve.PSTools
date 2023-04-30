function New-PaketDependenciesFile
{
    [CmdletBinding()]
    param
    (
        # The dependencies to be created
        [Parameter(Mandatory = $true)]
        [PaketDependency[]]
        $PaketDependencies,

        # Any manually defined dependencies
        [Parameter(Mandatory = $false)]
        [string]
        $ManualDependencies
    )
    
    begin
    {
        
    }
    
    process
    {
        $PaketDependenciesTemplate = "# This file is managed by a tool, manual changes will be lost unless added to the designated section below`n`n"
        # Add the main nuget source
        $PaketDependencies += 'source https://api.nuget.org/v3/index.json'
        if ($PaketDependencies)
        {
            $PaketDependenciesTemplate += "## Auto generated dependencies: ##`n"
            $PaketDependencies | ForEach-Object {
                if ($_.Comment)
                {
                    $PaketDependenciesTemplate += "$($_.Comment)`n"
                }
                $_.Item | ForEach-Object {
                    $PaketDependenciesTemplate += "$($_.Rule.Source) $($_.Rule.PackageName)`n"
                }
                $PaketDependenciesTemplate += "`n"
            }
        }
        $PaketDependenciesTemplate += "## Manually defined dependencies: ##`n"
        if ($ManualDependencies)
        {
            $PaketDependenciesTemplate += $ManualDependencies
        }
    }
    
    end
    {
        return $PaketDependenciesTemplate
    }
}
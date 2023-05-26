function New-GitHubActionsWorkflow
{
    [CmdletBinding()]
    param
    (
        # The name of the workflow
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        # When the workflow should be executed
        [Parameter(Mandatory = $true)]
        [string]
        $ExecuteOn,

        # The jobs to be run
        [Parameter(Mandatory = $true)]
        [GitHubActionsJob]
        $Jobs
    )
    
    begin
    {
        
    }
    
    process
    {
        $Yaml = "---`n# This file is created by a tool, modifications may be lost.`n"
        $ToConvert = [ordered]@{
            name = $Name
            on   = @{ $ExecuteOn = $null }
            jobs = [ordered]@{ $Jobs.JobTitle = [ordered]@{
                    'runs-on' = $Jobs.RunsOn
                    steps     = $Jobs.Steps
                }
            }
        }
        $ConvertedYaml = $ToConvert | ConvertTo-Yaml -KeepArray # Keep array seems to be needed to maintain the correct ordering of our parameters 🤔
        $Yaml = $Yaml + $ConvertedYaml
        # "|-" in yaml does not preserve line breaks, we most likely want to, so replace that for the run command
        $Yaml = $Yaml -replace 'run\: \|\-','run: |'
        
    }
    end
    {
        return $Yaml
    }
}
    

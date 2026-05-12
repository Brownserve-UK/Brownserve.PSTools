function New-BrownserveGitHubStageReleaseWorkflow
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName
    )
    begin
    {
        try
        {
            $Template = Get-Content (Join-Path $PSScriptRoot 'templates' 'psmodule_github_stage-release.yaml.template') -Raw
        }
        catch
        {
            throw "Failed to import stage-release workflow template.`n$($_.Exception.Message)"
        }
    }
    process
    {
        return $Template -replace '###MODULE_NAME###', $ModuleName
    }
    end
    {
    }
}

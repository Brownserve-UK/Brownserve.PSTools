function New-BrownserveGitHubBuildsWorkflow
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
            $Template = Get-Content (Join-Path $PSScriptRoot 'templates' 'psmodule_github_builds.yaml.template') -Raw
        }
        catch
        {
            throw "Failed to import builds workflow template.`n$($_.Exception.Message)"
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

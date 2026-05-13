function New-BrownserveGitHubReleaseWorkflow
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
            $Template = Get-Content (Join-Path $PSScriptRoot 'templates' 'psmodule_github_release.yaml.template') -Raw
        }
        catch
        {
            throw "Failed to import release workflow template.`n$($_.Exception.Message)"
        }
    }
    process
    {
        $Template = $Template -replace '###MODULE_NAME###', $ModuleName

        return $Template
    }
    end
    {
    }
}

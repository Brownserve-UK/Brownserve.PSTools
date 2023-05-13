function Get-VSCodeWorkspaceSettings
{
    [CmdletBinding()]
    param
    (
        # The path to the repo
        [Parameter(Mandatory = $true)]
        [string]
        $WorkspacePath
    )
    
    begin
    {
        
    }
    
    process
    {
        Assert-Directory $WorkspacePath -ErrorAction 'stop'
        $RepoVSCodePath = Join-Path $WorkspacePath '.vscode'
        $RepoVSCodeSettingsPath = Join-Path $RepoVSCodePath 'settings.json'

        if (Test-Path $RepoVSCodeSettingsPath)
        {
            try
            {
                $CurrentSettings = Get-Content $RepoVSCodeSettingsPath -Raw | ConvertFrom-Json -AsHashtable
                if (!$CurrentSettings)
                {
                    $CurrentSettings = $null
                }
            }
            catch
            {
                throw "Failed to import current VSCode settings from '$RepoVSCodeSettingsPath'.`n$($_.Exception.Message)"
            }
        }
        else
        {
            $CurrentSettings = $null
        }
    }
    
    end
    {
        if ($CurrentSettings)
        {
            return $CurrentSettings
        }
        else
        {
            return $null
        }
    }
}